require 'application_system_test_case'

class EditTest < ApplicationSystemTestCase
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

    context 'edit document' do
      should 'before signed' do
        visit edit_users_document_path(@document)
        assert_selector '#main-content .card-header', text: I18n.t('views.document.links.edit')
        assert_field 'document_title', with: @document.title
      end

      should 'after signed' do
        visit edit_users_document_path(@document_signer)
        assert_selector('div.alert.alert-warning', text: I18n.t('flash.actions.edit.non'))
      end
    end

    context 'message to edit the document even though it is already signed' do
      should 'successfully' do
        visit edit_users_document_path(@document_signer)
        enable_for_editing = "Caso deseja editar o documento #{@document_signer.title} clique aqui"
        assert_selector('div.alert.alert-info', text: enable_for_editing)
      end
    end

    context 'add justification' do
      should 'successfully' do
        visit edit_users_document_path(@document_signer)
        click_link 'clique aqui'
        fill_in 'document_justification', with: 'Justificativa abc'
        click_link_or_button I18n.t('simple_form.buttons.save')
        assert_selector('div.alert.alert-success', text: I18n.t('flash.actions.edit.success'))
      end

      should 'unsuccessfully' do
        visit edit_users_document_path(@document_signer)
        click_link 'clique aqui'
        fill_in 'document_justification', with: ''
        click_link_or_button I18n.t('simple_form.buttons.save')
        assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.edit.error'))
      end
    end
  end
end
