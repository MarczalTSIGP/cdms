require 'application_system_test_case'

class DocumentRecipientTest < ApplicationSystemTestCase
  context 'document_recipients' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)

      department = create(:department)
      department.department_users.create(user: @user)
      @document = create(:document, :certification, department: department)

      visit users_document_recipients_path(@document.id)
    end

    context 'add recipient' do
      should 'before signed' do
        assert_selector '#main-content .card-header', text: @document.title

        assert_selector "a[href='#{users_new_recipient_document_path(@document)}']",
                        text: I18n.t('views.document.recipients.new')
      end

      should 'after signed' do
        create(:document_signer, document: @document, signed: true)

        visit users_document_recipients_path(@document)
        assert_selector('div.alert.alert-info',
                        text: I18n.t('views.document.recipients.document_has_signature'))
        assert_selector "a[href='#{users_new_recipient_document_path(@document)}']",
                        text: I18n.t('views.document.recipients.new'), count: 0
      end
    end
  end
end
