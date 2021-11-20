require 'application_system_test_case'

class UpdateTest < ApplicationSystemTestCase
  context 'change' do
    setup do
      user = create(:user, :manager)
      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)
      @document = create(:document, :certification, department: @department)

      login_as(user, as: :user)
    end
    should 'not be active' do
      visit users_documents_path
      within('tbody tr td label.ml-1.document_checkbox_label') do
        assert_text(I18n.t('activerecord.attributes.document.' + false))
      end
    end
    should 'change to active' do
      visit users_documents_path
      find('#active').click
      visit users_documents_path
      within('tbody tr td label.ml-1.document_checkbox_label') do
        assert_text(I18n.t('activerecord.attributes.document.' + true))
      end
    end
  end
end
