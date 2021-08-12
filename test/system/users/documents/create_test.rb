require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)

      visit new_users_document_path

      sign_in user
    end

    should 'successfully' do
      document = build(:document)

      fill_in 'document_title', with: document.title

      find('#document_category-selectized').click
      find('.selectize-dropdown-content .option[data-value="declaration"]').click

      find('#document_department_id-selectized').click
      find(".selectize-dropdown-content .option[data-value='#{@department.id}']").click

      page.execute_script("document.getElementById('document_front_text').innerText = '#{document.front_text}'")
      page.execute_script("document.getElementById('document_back_text').innerText = '#{document.back_text}'")

      find('#add_variable_button').click
      fill_in 'variable_name', with: 'Student name'
      fill_in 'variable_identifier', with: 'student-name'
      find('#add_variable').click

      submit_form

      flash_message = I18n.t('flash.actions.create.m', resource_name: Document.model_name.human)
      assert_selector('div.alert.alert-success', text: flash_message)

      document = Document.last
      within('table.table tbody') do
        assert_text document.title

        assert_selector "a[href='#{users_preview_document_path(document)}']"
        assert_selector "a[href='#{users_document_path(document)}'][data-method='delete']"
      end

      visit edit_users_document_path(document)
      within('table#variables-table tbody') do
        assert_selector 'tr:nth-child(1) td:nth-child(1)', text: 'Student name'
      end

      #TODO
      visit edit_users_document_path(document)
      find('#defaultVariable_email').click
      find('add_default_variable').click
      assert_selector('#document_front_text', text: '{email}')

    end

    should 'unsuccessfully' do
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.document_title') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.document_category') do
        assert_text(I18n.t('errors.messages.inclusion'))
      end

      within('div.document_department_id') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.document_front_text') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.document_back_text') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
