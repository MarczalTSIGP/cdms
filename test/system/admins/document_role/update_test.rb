require 'application_system_test_case'

class UpdateTest < ApplicationSystemTestCase
  context 'update' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)

      @document_role = create(:document_role)
      visit edit_admins_document_role_path(@document_role)
    end

    should 'fill the fields' do
      assert_field 'name', with: @document_role.name
      assert_field 'description', with: @document_role.description
    end

    should 'successfully' do
      document_role = build(:document_role)

      fill_in 'name', with: document_role.name
      fill_in 'description', with: document_role.description

      submit_form

      flash_message = I18n.t('flash.actions.update.f', resource_name: t('views.document_role.name.singular'))
      assert_selector('div.alert.alert-success', text: flash_message)
    end

    should 'unsuccessfully' do
      fill_in 'name', with: ''
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.document_role_name') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
