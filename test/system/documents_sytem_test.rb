require 'application_system_test_case'

class DocumentsTest < ApplicationSystemTestCase
  context 'public' do
    setup do
      @document_recipient = create(:document_recipient, :user)
    end

    should 'display index' do
      visit documents_path

      assert_selector '#document-form-background .document-form .form-input', text: I18n.t('views.documents.code')
    end

    should 'index form' do
      visit documents_path
      within('.document-form') do
        fill_in 'document_code', with: @document_recipient.verification_code
        click_button 'commit'
      end
    end

    should 'show document with valid code' do
      visit show_document_path(@document_recipient.verification_code)

      assert_selector('div.alert.alert-success',
                      text: I18n.t('views.documents.valid_code', code: @document_recipient.verification_code))
      assert_selector('div.recipients-code', text: @document_recipient.verification_code)
    end

    should 'show document with invalid code' do
      visit show_document_path('invalid_code')

      assert_selector('div.alert.alert-warning',
                      text: I18n.t('views.documents.not_exist_document', code: 'invalid_code'))
    end
  end
end
