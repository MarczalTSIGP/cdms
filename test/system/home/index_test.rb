require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'navbar' do
    should 'have links' do
      visit root_path
      
      assert_selector "a[href='#{root_path}']", text: I18n.t('views.links.public.home')
      assert_selector "a[href='#{about_path}']", text: I18n.t('views.links.public.about')
      assert_selector "a[href='#{login_path}']", text: I18n.t('views.links.public.login')
    end

    should 'be navigable' do
      visit root_path

      click_on I18n.t('views.links.public.about')
      assert_current_path(about_path)

      click_on I18n.t('views.links.public.login')
      assert_current_path(login_path)

      click_on I18n.t('views.links.public.home')
      assert_current_path(root_path)
    end

    should 'display sign in links' do
      visit login_path

      selector = "a[href='#{new_user_session_path}']"
      assert_selector selector, text: I18n.t('views.links.public.user.sign_in')
      assert_selector selector, text: I18n.t('views.links.public.audience_member.sign_in')
    end
  end
end
