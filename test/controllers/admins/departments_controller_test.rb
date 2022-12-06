require 'test_helper'

class Admins::DepartmentsControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @department = create(:department)
      @user = create(:user)
      sign_in create(:user, :manager)
    end

    should 'get index' do
      get admins_departments_path
      assert_response :success
      assert_active_link(href: admins_departments_path)
    end

    should 'get new' do
      get new_admins_department_path
      assert_response :success
      assert_active_link(href: admins_departments_path)
    end

    should 'get show' do
      get admins_department_path(@department)
      assert_response :success
      assert_active_link(href: admins_departments_path)
    end

    should 'get edit' do
      get edit_admins_department_path(@department)
      assert_response :success
      assert_active_link(href: admins_departments_path)
    end

    context '#create' do
      should 'successfully' do
        assert_difference('Department.count', 1) do
          post admins_departments_path, params: { department: attributes_for(:department) }
        end
        assert_redirected_to admins_departments_path
        assert_equal I18n.t('flash.actions.create.m', resource_name: Department.model_name.human),
                     flash[:success]
        follow_redirect!
        assert_active_link(href: admins_departments_path)
      end

      should 'unsuccessfully' do
        assert_no_difference('Department.count') do
          post admins_departments_path, params: { department: attributes_for(:department, name: '') }
        end

        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]
        assert_active_link(href: admins_departments_path)
      end
    end

    context '#update' do
      should 'successfully' do
        patch admins_department_path(@department), params: { department: { name: 'updated' } }
        assert_redirected_to admins_departments_path
        assert_equal I18n.t('flash.actions.update.m', resource_name: Department.model_name.human),
                     flash[:success]
        @department.reload
        assert_equal 'updated', @department.name
        follow_redirect!
        assert_active_link(href: admins_departments_path)
      end

      should 'unsuccessfully' do
        patch admins_department_path(@department), params: { department: { name: '' } }
        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]

        name = @department.name
        @department.reload
        assert_equal name, @department.name
        assert_active_link(href: admins_departments_path)
      end
    end

    should 'destroy' do
      assert_difference('Department.count', -1) do
        delete admins_department_path(@department)
      end

      assert_redirected_to admins_departments_path
    end

    context 'members' do
      should 'get members' do
        get admins_department_members_path(@department)
        assert_response :success
        assert_active_link(href: admins_departments_path)
      end

      context 'add' do
        should 'successfully' do
          user = create(:user)
          params = { user_id: user.id, department_id: @department.id, role: :collaborator }

          assert_difference('DepartmentUser.count', 1) do
            headers = { 'HTTP_REFERER' => admins_department_members_path(@department) }
            post admins_department_add_member_path(@department),
                 params: { member: params },
                 headers: headers
          end

          assert_redirected_to admins_department_members_path(@department)
          assert_equal I18n.t('flash.actions.add.m', resource_name: User.model_name.human), flash[:success]
          @department.reload
          assert_equal 1, @department.users.count
          follow_redirect!
          assert_active_link(href: admins_departments_path)
        end

        should 'unsuccessfully' do
          post admins_department_add_member_path(@department), params: { member: { user_id: '' } }
          assert_response :success
          @department.reload
          assert_equal 0, @department.users.count
        end
      end

      should 'remove' do
        du = create(:department_user, :collaborator, department: @department)

        assert_difference('DepartmentUser.count', -1) do
          delete admins_department_remove_member_path(@department, du.user),
                 headers: { 'HTTP_REFERER' => admins_department_members_path(@department) }
        end

        assert_redirected_to admins_department_members_path(@department)
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
      get: [admins_departments_path, new_admins_department_path,
            edit_admins_department_path(1), admins_department_path(1),
            admins_department_members_path(1)],
      post: [admins_departments_path, admins_department_add_member_path(1)],
      patch: [admins_department_path(1)],
      delete: [admins_department_path(1), admins_department_remove_member_path(1, 1)]
    }
  end
end
