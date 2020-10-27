require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
      @department = create(:department)

      visit new_users_document_path
    end

    should 'successfully' do
      document = build(:document)

      fill_in 'document_title', with: document.title
      # fill_in 'document_front_text', with: document.front_text
      # fill_in 'document_back_text', with: document.back_text

      find(".selectize-dropdown-content .option[data-value='declaration']").click
      find('#document_department_id-selectized').click

      submit_form

      flash_message = I18n.t('flash.actions.create.m', resource_name: Department.model_name.human)
      assert_selector('div.alert.alert-success', text: flash_message)

      document = Document.last
      within('table.table tbody') do
        assert_selector "a[href='#{users_document_path(document)}']", text: document.id
        assert_text document.title

        assert_selector "a[href='#{users_preview_document_path(document)}']"
        assert_selector "a[href='#{users_document_path(document)}'][data-method='delete']"
      end
    end

    should 'unsuccessfully' do
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.document_title') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
