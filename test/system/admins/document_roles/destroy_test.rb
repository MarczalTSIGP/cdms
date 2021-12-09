require 'application_system_test_case'

class DestroyTest < ApplicationSystemTestCase
  context 'document_role' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
    end

    should 'destroy a document role' do
      document_role = create(:document_role)
      visit admins_document_roles_path

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{admins_document_role_path(document_role)}'][data-method='delete']").click
        end
      end

      assert_current_path admins_document_roles_path
      flash_message = I18n.t('activerecord.models.document_role.one')
      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.destroy.f', resource_name: flash_message))

      within('table.table tbody') do
        refute_text document_role.name
        refute_selector "a[href='#{edit_admins_document_role_path(document_role)}']"
        refute_selector "a[href='#{admins_document_role_path(document_role)}'][data-method='delete']"
      end
    end
  end
end
