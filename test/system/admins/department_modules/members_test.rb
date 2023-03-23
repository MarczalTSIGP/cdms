require 'application_system_test_case'

class MembersTest < ApplicationSystemTestCase
  context 'department module' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)
    end

    context 'add member' do
      setup do
        @user = create(:user)
        @module = create(:department_module)
        @department = @module.department
        visit admins_department_module_members_path(@department, @module)
      end

      should 'successfully' do
        fill_in 'department_module_user_user', with: @user.name
        find("#department_module_user_user-dropdown .dropdown-item[data-value='#{@user.id}']").click

        find_by_id('department_module_user_role-selectized').click
        find('.selectize-dropdown .option[data-value=collaborator]').click

        submit_form("button[type='submit']")

        base_selector = '.table tbody tr:nth-child(1)'

        assert_selector(base_selector, text: @user.name)
        assert_selector(base_selector, text: @user.email)
        assert_selector(base_selector, text: @user.role)
      end

      should 'unsuccessfully' do
        fill_in 'department_module_user_user', with: @user.name
        find("#department_module_user_user-dropdown .dropdown-item[data-value='#{@user.id}']").click

        submit_form("button[type='submit']")
        base_selector = '.table tbody tr:nth-child(1)'

        assert_no_selector(base_selector, text: @user.name)
        assert_no_selector(base_selector, text: @user.email)
        assert_no_selector(base_selector, text: @user.role)
      end
    end

    should 'remove member' do
      department_module_user = create(:department_module_user, role: :collaborator)
      user = department_module_user.user
      department_module = department_module_user.department_module
      department = department_module_user.department_module.department

      visit admins_department_module_members_path(department, department_module)

      accept_confirm do
        find("a[href='#{admins_department_module_remove_member_path(department, department_module, user)}']").click
      end
      base_selector = '.table tbody tr:nth-child(1)'

      assert_no_selector(base_selector, text: user.name)
    end
  end
end
