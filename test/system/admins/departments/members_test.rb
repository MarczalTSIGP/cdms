require 'application_system_test_case'

class MembersTest < ApplicationSystemTestCase
  context 'department' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)
    end

    context 'add member' do
      setup do
        @department = create(:department)
        @user = create(:user)
        visit admins_department_members_path(@department)
      end

      should 'successfully' do
        fill_in 'department_user_user', with: @user.name
        find("#department_user_user-dropdown .dropdown-item[data-value='#{@user.id}']").click

        find_by_id('department_user_role-selectized').click
        find('.selectize-dropdown-content .option[data-value="responsible"]').click

        submit_form("button[type='submit']")

        base_selector = 'table tbody tr:nth-child(1)'

        assert_current_path admins_department_members_path(@department)
        assert_selector base_selector, text: @user.name
        assert_selector base_selector, text: @user.email
        assert_selector base_selector, text: I18n.t('enums.roles.responsible')
      end

      should 'unsuccessfully' do
        submit_form("button[type='submit']")

        within('div.department_user_user') do
          assert_text(I18n.t('errors.messages.required'))
        end

        within('div.department_user_role') do
          assert_text(I18n.t('errors.messages.inclusion'))
        end
      end
    end

    should 'remove a member' do
      du = create(:department_user, :collaborator)
      user = du.user
      department = du.department

      visit admins_department_members_path(department)

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{admins_department_remove_member_path(department, user)}'][data-method='delete']").click
        end
      end

      assert_current_path admins_department_members_path(department)
      flash_message = User.model_name.human

      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.remove.m', resource_name: flash_message))

      within('table.table tbody') do
        refute_text user.name
        refute_selector "a[href='#{admins_department_remove_member_path(department, user)}'][data-method='delete']"
      end
    end
  end
end
