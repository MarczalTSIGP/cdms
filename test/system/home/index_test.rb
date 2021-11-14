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
  end
end
