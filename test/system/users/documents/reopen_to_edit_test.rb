require 'application_system_test_case'

class ReopenToEditTest < ApplicationSystemTestCase
  context 'document' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)

      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)
      @document = create(:document, :certification, department: @department)
      @document_signer = create(:document, :certification, department: @department)
      create(:document_signer, document: @document_signer, signed: true)
    end

    context 'add justification' do
      should 'successfully' do
        visit edit_users_document_path(@document_signer)
        click_link I18n.t('views.links.click_here')
        fill_in 'document_justification', with: 'Justificativa abc'

        click_link_or_button I18n.t('simple_form.buttons.save')
        assert_selector('div.alert.alert-success', text: I18n.t('flash.actions.reopen_document.success'))
      end

      should 'unsuccessfully' do
        visit edit_users_document_path(@document_signer)
        click_link I18n.t('views.links.click_here')
        fill_in 'document_justification', with: ''
        click_link_or_button I18n.t('simple_form.buttons.save')

        assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.reopen_document.error'))
      end
    end
  end
end
