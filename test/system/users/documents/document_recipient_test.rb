require 'application_system_test_case'

class DocumentRecipientTest < ApplicationSystemTestCase
  context 'document_recipients' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)

      @audience_member = create(:audience_member)
      department = create(:department)
      department.department_users.create(user: @user)
      @document = create(:document, :certification, department: department)
      visit users_document_recipients_path(@document.id)
    end

    context 'add recipient' do
      should 'before signed' do
        assert_selector '#main-content .card-header', text: @document.title
        has_link?(I18n.t('views.links.add'))
      end

      should 'after signed' do
        department = create(:department)
        document = create(:document, :certification, department: department)
        create(:document_signer, document: document, signed: true)
        visit users_document_recipients_path(document.id)
        assert_selector('div.alert.alert-info', text: I18n.t('views.document.recipients.document_has_signature'))
      end
    end
  end
end
