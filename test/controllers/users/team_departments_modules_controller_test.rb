require 'test_helper'

class Users::TeamDepartmentsModulesControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @department = create(:department)
      @user = create(:user)
      @department_user = create(:department_user, :collaborator, user: @user, department: @department)

      @module = create(:department_module, department: @department)
      @module_user = create(:department_module_user, :collaborator, user: @user, department_module: @module)

      sign_in @user
    end

    should 'get index' do
      get users_team_departments_modules_path

      assert_response :success
      assert_active_link(href: users_team_departments_modules_path)
      assert_breadcrumbs({ text: I18n.t('views.breadcrumbs.home') })
    end

    context 'get show department' do
      should 'successfully' do
        get users_show_department_path(@department)

        assert_response :success

        assert_breadcrumbs({ link: users_root_path, text: I18n.t('views.breadcrumbs.home') },
                           { link: users_team_departments_modules_path, text: I18n.t('views.team.name.plural') },
                           { text: I18n.t('views.department.links.show') })
      end

      should 'unsuccessfully' do
        department = create(:department)
        get users_show_department_path(department)

        assert_redirected_to users_team_departments_modules_path
      end
    end

    context 'get show module' do
      should 'successfully' do
        get users_show_module_path(@module)

        assert_response :success

        assert_breadcrumbs({ link: users_root_path, text: I18n.t('views.breadcrumbs.home') },
                           { link: users_team_departments_modules_path, text: I18n.t('views.team.name.plural') },
                           { text: I18n.t('views.department_module.links.show') })
      end

      should 'unsuccessfully' do
        department_module = create(:department_module)
        get users_show_module_path(department_module)

        assert_redirected_to users_team_departments_modules_path
      end
    end
  end
end
