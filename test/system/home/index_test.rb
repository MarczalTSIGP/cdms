require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'links' do
    should 'have sign_in' do
      visit root_path
      assert_selector "a[href='#{new_user_session_path}']", text: I18n.t('views.links.home.user.sign_in')
      assert_selector "a[href='#']", text: I18n.t('views.links.home.audience_member.sign_in')
    end
  end
end
