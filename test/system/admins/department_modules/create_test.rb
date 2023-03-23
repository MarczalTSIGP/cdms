require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)

      @department = create(:department)
      visit new_admins_department_module_path(@department)
    end

    should 'successfully' do
      d_module = build(:department_module)

      fill_in 'department_module_name', with: d_module.name
      fill_in 'department_module_description', with: d_module.description
      submit_form

      flash_message = I18n.t('flash.actions.create.m', resource_name: DepartmentModule.model_name.human)

      assert_selector('div.alert.alert-success', text: flash_message)

      d_module = DepartmentModule.last
      within('.card.modules table.table tbody') do
        assert_text d_module.name
        assert_text d_module.description

        assert_selector "a[href='#{edit_admins_department_module_path(@department, d_module)}']"
        assert_selector "a[href='#{admins_department_module_path(@department, d_module)}'][data-method='delete']"
      end
    end

    should 'unsuccessfully' do
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.department_module_name') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.department_module_description') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
