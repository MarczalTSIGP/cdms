require 'application_system_test_case'

class UpdateTest < ApplicationSystemTestCase
  context 'update' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)

      @department = create(:department)
      visit edit_admins_department_path(@department)
    end

    should 'fill the fields' do
      assert_field 'department_name', with: @department.name
      assert_field 'department_initials', with: @department.initials
      assert_field 'department_phone', with: @department.phone
      assert_field 'department_local', with: @department.local
      assert_field 'department_email', with: @department.email
      assert_field 'department_description', with: @department.description
    end

    should 'successfully' do
      department = build(:department)

      fill_in 'department_name', with: department.name
      fill_in 'department_initials', with: department.initials
      fill_in 'department_phone', with: department.phone
      fill_in 'department_local', with: department.local
      fill_in 'department_email', with: department.email
      fill_in 'department_description', with: department.description
      submit_form

      flash_message = I18n.t('flash.actions.update.m', resource_name: Department.model_name.human)

      assert_selector('div.alert.alert-success', text: flash_message)

      within('table.table tbody') do
        assert_selector "a[href='#{admins_department_path(@department)}']", text: department.initials
        assert_text department.name
        assert_text department.phone
        assert_text department.local
        assert_text department.email
      end
    end

    should 'unsuccessfully' do
      fill_in 'department_name', with: ''
      fill_in 'department_initials', with: ''
      fill_in 'department_phone', with: ''
      fill_in 'department_local', with: ''
      fill_in 'department_email', with: ''
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.department_name') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.department_initials') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.department_phone') do
        assert_text(I18n.t('errors.messages.invalid'))
      end

      within('div.department_local') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.department_email') do
        assert_text(I18n.t('errors.messages.invalid'))
      end
    end
  end
end
