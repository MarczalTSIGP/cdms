require 'application_system_test_case'

class UpdateTest < ApplicationSystemTestCase
  context 'update' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)

      @page = create(:page)
      visit admins_edit_about_page_path
    end

    should 'successfully' do
      page.execute_script("document.getElementById('page_content').innerText = '#{@page.content}'")
      submit_form

      flash_message = I18n.t('flash.actions.update.m', resource_name: @page.model_name.human)

      assert_selector('div.alert.alert-success', text: flash_message)
      within('div.page_content') do
        assert_text(@page.content)
      end
    end

    should 'unsuccessfully' do
      page.execute_script("document.getElementById('page_content').innerText = ''")
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))
      within('div.page_content') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
