require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
      visit new_admins_department_path
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

      flash_message = I18n.t('flash.actions.create.m', resource_name: Department.model_name.human)

      assert_selector('div.alert.alert-success', text: flash_message)

      department = Department.last

      within('table.table tbody') do
        assert_selector "a[href='#{admins_department_path(department)}']", text: department.name
        assert_text department.phone
        assert_text department.email
        assert_text department.responsible&.name
        assert_text department.department_users.size

        assert_selector "a[href='#{admins_department_members_path(department)}']"
        assert_selector "a[href='#{edit_admins_department_path(department)}']"
        assert_selector "a[href='#{admins_department_path(department)}'][data-method='delete']"
      end
    end

    should 'mask phone' do
      fill_in 'department_phone', with: '42998300990'.chars.join(' ')

      assert_field 'department_phone', with: '(42) 99830-0990'
    end

    should 'unsuccessfully' do
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
