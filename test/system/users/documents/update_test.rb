require 'application_system_test_case'

class UpdateTest < ApplicationSystemTestCase
  context 'update' do
    setup do
      user = create(:user, :manager)
      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)
      @document = create(:document, :certification, department: @department)

      login_as(user, as: :user)

      visit edit_users_document_path(@document)
    end

    should 'fill the fields' do
      assert_field 'document_title', with: @document.title
    end

    should 'successfully' do
      document = build(:document)

      fill_in 'document_title', with: document.title
      page.execute_script("document.getElementById('document_front_text').innerText = '#{document.front_text}'")
      submit_form

      flash_message = I18n.t('flash.actions.update.m', resource_name: document.model_name.human)

      assert_selector('div.alert.alert-success', text: flash_message)
      within('table.table tbody') do
        assert_text document.title
      end
    end

    should 'unsuccessfully' do
      fill_in 'document_title', with: ''
      page.execute_script("document.getElementById('document_front_text').innerText = ''")
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.document_title') do
        assert_text(I18n.t('errors.messages.blank'))
      end

      within('div.document_front_text') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
