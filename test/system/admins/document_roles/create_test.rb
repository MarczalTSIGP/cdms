require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
      visit new_admins_document_role_path
    end

    should 'successfully' do
      document_role = build(:document_role)

      fill_in 'name', with: document_role.name
      fill_in 'description', with: document_role.description

      submit_form
      flash_message = I18n.t('flash.actions.add.f', resource_name: t('views.document_role.name.singular'))

      assert_selector('div.alert.alert-success', text: flash_message)

      document_role = DocumentRole.last
      within('table.table tbody') do
        assert_selector "a[href='#{admins_document_role_path(document_role)}']", text: document_role.name
        assert_text document_role.description
      end
    end

    should 'unsuccessfully' do
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))
      within('div.name') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
