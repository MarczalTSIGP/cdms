require 'application_system_test_case'

class DestroyTest < ApplicationSystemTestCase
  context 'document' do
    setup do
      user = create(:user, :manager)
      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)

      login_as(user, as: :user)

      visit new_users_document_path
    end

    should 'destroy a document' do
      document = create(:document, :certification, department: @department)
      visit search_users_documents_path

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{users_document_path(document)}'][data-method='delete']").click
        end
      end

      assert_current_path users_documents_path
      flash_message = I18n.t('activerecord.models.document.one')

      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.destroy.m', resource_name: flash_message))

      within('table.table tbody') do
        refute_text document.title
        refute_selector "a[href='#{edit_users_document_path(document)}']"
        refute_selector "a[href='#{users_document_path(document)}'][data-method='delete']"
      end
    end
  end
end
