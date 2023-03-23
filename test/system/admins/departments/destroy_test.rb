require 'application_system_test_case'

class DestroyTest < ApplicationSystemTestCase
  context 'department' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
    end

    should 'destroy a department' do
      department = create(:department)
      visit admins_departments_path

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{admins_department_path(department)}'][data-method='delete']").click
        end
      end

      assert_current_path admins_departments_path
      flash_message = I18n.t('activerecord.models.department.one')

      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.destroy.m', resource_name: flash_message))

      within('table.table tbody') do
        refute_text department.name
        refute_selector "a[href='#{edit_admins_department_path(department)}']"
        refute_selector "a[href='#{admins_department_path(department)}'][data-method='delete']"
      end
    end
  end
end
