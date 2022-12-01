require 'test_helper'

class Admins::DepartmentModulesControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @module = create(:department_module)
      @department = @module.department
      @user = create(:user)
      sign_in create(:user, :manager)
    end

    teardown do
      assert_active_link(href: admins_departments_path)
    end

    should 'get new' do
      get new_admins_department_module_path(@department)
      assert_response :success

      assert_breadcrumbs({ link: admins_root_path,        text: I18n.t('views.breadcrumbs.home') },
                         { link: admins_departments_path, text: Department.model_name.human(count: 2) },
                         { text: I18n.t('views.breadcrumbs.show', model: @department.model_name.human,
                                                                  id: @department.id) },
                         { text: I18n.t('views.breadcrumbs.new.m') })
    end

    should 'get edit' do
      get edit_admins_department_module_path(@department, @module)
      assert_response :success

      assert_breadcrumbs({ link: admins_root_path,        text: I18n.t('views.breadcrumbs.home') },
                         { link: admins_departments_path, text: Department.model_name.human(count: 2) },
                         { text: I18n.t('views.breadcrumbs.show', model: @department.model_name.human,
                                                                  id: @department.id) },
                         { text: I18n.t('views.breadcrumbs.show', model: @module.model_name.human,
                                                                  id: @module.id) },
                         { text: I18n.t('views.breadcrumbs.edit') })
    end

    context '#create' do
      should 'successfully' do
        assert_difference('DepartmentModule.count', 1) do
          post admins_department_modules_path(@department),
               params: { department_module: attributes_for(:department_module) }
        end
        assert_redirected_to admins_department_path(@department)
        assert_equal I18n.t('flash.actions.create.m', resource_name: DepartmentModule.model_name.human),
                     flash[:success]
        follow_redirect!
      end

      should 'unsuccessfully' do
        assert_no_difference('DepartmentModule.count') do
          post admins_department_modules_path(@department),
               params: { department_module: attributes_for(:department_module, name: '') }
        end

        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]

        assert_breadcrumbs({ link: admins_root_path,        text: I18n.t('views.breadcrumbs.home') },
                           { link: admins_departments_path, text: Department.model_name.human(count: 2) },
                           { text: I18n.t('views.breadcrumbs.show', model: @department.model_name.human,
                                                                    id: @department.id) },
                           { link: new_admins_department_module_path(@department),
                             text: I18n.t('views.breadcrumbs.new.m') })
      end
    end

    context '#update' do
      should 'successfully' do
        patch admins_department_module_path(@department, @module), params: { department_module: { name: 'updated' } }
        assert_redirected_to admins_department_path(@department)
        assert_equal I18n.t('flash.actions.update.m', resource_name: DepartmentModule.model_name.human),
                     flash[:success]
        @module.reload
        assert_equal 'updated', @module.name
        follow_redirect!
      end

      should 'unsuccessfully' do
        patch admins_department_module_path(@department, @module), params: { department_module: { name: '' } }
        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]

        name = @module.name
        @module.reload
        assert_equal name, @module.name

        assert_breadcrumbs({ link: admins_root_path, text: I18n.t('views.breadcrumbs.home') },
                           { link: admins_departments_path, text: Department.model_name.human(count: 2) },
                           { text: I18n.t('views.breadcrumbs.show', model: @department.model_name.human,
                                                                    id: @department.id) },
                           { text: I18n.t('views.breadcrumbs.show', model: @module.model_name.human,
                                                                    id: @module.id) },
                           { link: edit_admins_department_module_path(@department, @module),
                             text: I18n.t('views.breadcrumbs.edit') })
      end
    end

    should 'destroy' do
      assert_difference('DepartmentModule.count', -1) do
        delete admins_department_module_path(@department, @module)
      end

      assert_redirected_to admins_department_path(@department)
      follow_redirect!
    end

    context 'members' do
      should 'get members' do
        get admins_department_module_members_path(@department, @module)
        assert_response :success
        assert_active_link(href: admins_departments_path)
      end

      should 'add member' do
        user = create(:user)
        params = { user_id: user.id, department_module: @module.id, role: :collaborator }

        assert_difference('DepartmentModuleUser.count', 1) do
          post admins_department_module_add_member_path(@department, @module),
               params: { member: params },
               headers: { 'HTTP_REFERER' => admins_department_module_members_path(@department, @module) }
        end

        assert_redirected_to admins_department_module_members_path(@department, @module)
        follow_redirect!
        @module.reload
        assert_equal 1, @module.users.count
      end

      should 'not add member without role' do
        user = create(:user)
        params = { user_id: user.id, department_module: @module.id }

        assert_difference('DepartmentModuleUser.count', 0) do
          post admins_department_module_add_member_path(@department, @module), params:
           { member: params }
        end

        assert_response :success
        @module.reload
        assert_equal 0, @module.users.count
      end

      should 'dont add twice with diffent roles' do
        responsible = create(:department_module_user, department_module: @module, role: :collaborator)
        params = { user_id: responsible.id, department_module: @module, role: :responsible }

        assert_no_difference('DepartmentModuleUser.count') do
          post admins_department_module_add_member_path(@department, @module), params:
          { member: params }
        end

        @module.reload
        assert_equal 1, @module.users.count
      end

      should 'not add twice with same role' do
        responsible = create(:department_module_user, department_module: @module, role: :collaborator)
        params = { user_id: responsible.id, department_module: @module, role: :collaborator }

        assert_no_difference('DepartmentModuleUser.count') do
          post admins_department_module_add_member_path(@department, @module), params:
           { member: params }
        end

        @module.reload
        assert_equal 1, @module.users.count
      end

      should 'not add two responsibles' do
        create(:department_module_user, department_module: @module, role: :responsible)
        user = create(:user)
        params = { user_id: user.id, department_module: @module, role: :responsible }

        assert_no_difference('DepartmentModuleUser.count') do
          post admins_department_module_add_member_path(@department, @module), params:
           { member: params }
        end

        @module.reload
        assert_equal 1, @module.users.count
      end

      should 'remove member' do
        module_user = create(:department_module_user, department_module: @module, role: :collaborator)

        assert_difference('DepartmentModuleUser.count', -1) do
          headers = { 'HTTP_REFERER' => admins_department_module_members_path(@department, @module) }
          delete admins_department_module_remove_member_path(@department, @module, module_user.user),
                 headers: headers
        end

        assert_redirected_to admins_department_module_members_path(@department, @module)
        follow_redirect!
      end
    end
  end

  context 'unauthenticated' do
    should 'redirect to login when not authenticated' do
      assert_redirect_to(new_user_session_path)
    end

    should 'redirect to login when logged as non administrator user' do
      sign_in create(:user)
      assert_redirect_to(users_root_path)
    end
  end

  private

  def assert_redirect_to(redirect_to)
    requests.each do |method, routes|
      routes.each do |route|
        send(method, route)
        assert_redirected_to redirect_to
      end
    end
  end

  def requests
    {
      get: [new_admins_department_module_path(1),
            edit_admins_department_module_path(1, 1), admins_department_module_members_path(1, 1)],
      post: [admins_department_modules_path(1), admins_department_module_add_member_path(1, 1)],
      patch: [admins_department_module_path(1, 1)],
      delete: [admins_department_module_path(1, 1), admins_department_module_remove_member_path(1, 1, 1)]
    }
  end
end
