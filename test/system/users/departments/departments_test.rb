require 'application_system_test_case'

class DepartmentsTest < ApplicationSystemTestCase
  context 'users department' do
    setup do
      user = create(:user)
      @department_user = create(:department_user, :responsible, user: user)
      @department = @department_user.department

      login_as(user, as: :user)
    end

    should 'display the members of the department' do
      create_list(:department_user, 3, department: @department, role: DepartmentUser.roles[:collaborator])

      visit users_department_members_path(@department)

      assert_selector 'h1.page-title', text: I18n.t('views.department.members.nwdp', name: @department.name)

      within('table.table tbody') do
        @department.department_users.each_with_index do |department_user, index|
          user = department_user.user
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector base_selector, text: user.name
          assert_selector base_selector, text: user.email
          assert_selector base_selector, text: I18n.t("views.status.#{user.active?}")
          assert_selector base_selector, text: I18n.t("enums.roles.#{department_user.role}")
          assert_selector "#{base_selector}
                           a[href='#{users_department_remove_member_path(@department.id,
                                                                         user)}'][data-method='delete']"
        end
      end
    end

    should 'successfully add member' do
      user = create(:user)
      visit users_department_members_path(@department)

      fill_in 'department_user_user', with: user.name
      find("#department_user_user-dropdown .dropdown-item[data-value='#{user.id}']").click

      submit_form("button[type='submit']")

      assert_current_path users_department_members_path(@department)
      within('table.table tbody') do
        child = 2
        base_selector = "tr:nth-child(#{child})"

        assert_selector base_selector, text: user.name
        assert_selector base_selector, text: user.email
        assert_selector base_selector, text: I18n.t("views.status.#{user.active?}")
        assert_selector base_selector, text: I18n.t("enums.roles.#{DepartmentUser.roles[:collaborator]}")
        assert_selector "#{base_selector}
                           a[href='#{users_department_remove_member_path(@department.id,
                                                                         user)}'][data-method='delete']"
      end
    end

    should 'unsuccessfully add member' do
      visit users_department_members_path(@department)
      submit_form("button[type='submit']")

      assert_current_path users_department_members_path(@department)
      within('div.department_user_user') do
        assert_text(I18n.t('errors.messages.required'))
      end
    end

    should 'remove a member' do
      user = create(:user)
      create(:department_user, department: @department, user: user, role: DepartmentUser.roles[:collaborator])

      visit users_department_members_path(@department)

      within('table.table tbody') do
        accept_confirm do
          find("a[href='#{users_department_remove_member_path(@department,
                                                              user)}'][data-method='delete']").click
        end
      end

      assert_current_path users_department_members_path(@department)
      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.remove.m', resource_name: User.model_name.human))

      within('table.table tbody') do
        refute_text user.name
        refute_selector "a[href='#{users_department_remove_member_path(@department,
                                                                       user)}'][data-method='delete']"
      end
    end
  end
end
