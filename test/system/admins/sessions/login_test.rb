require 'application_system_test_case'

class LoginTest < ApplicationSystemTestCase
  context 'success login' do
    should 'displays flash and users profile link and sign out' do
      user = create(:user)

      visit new_user_session_path

      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'

      click_on I18n.t('views.session.new.submit')

      assert_current_path(users_root_path)
      assert_selector 'div.alert.alert-info', text: I18n.t('devise.sessions.signed_in')

      within 'div.header div.dropdown' do
        assert_selector "a[href='#{edit_user_registration_path}']", visible: false
        assert_selector "a[href='#{destroy_user_session_path}']", visible: false
        assert_selector 'span.text-default', text: user.name
        assert_selector 'small.text-muted', text: user.email
      end
    end
  end

  context 'unsuccess login' do
    should 'displays alert warning' do
      visit new_user_session_path

      click_on I18n.t('views.session.new.submit')

      assert_current_path(new_user_session_path)

      attribute_name = User.human_attribute_name(:email)
      assert_selector 'div.alert.alert-warning',
                      text: I18n.t('devise.failure.invalid', authentication_keys: attribute_name)
    end
  end

  context 'when user is not authenticated' do
    should 'redirect to login page' do
      visit users_root_path

      assert_current_path(new_user_session_path)
      assert_selector 'div.alert.alert-warning', text: I18n.t('devise.failure.unauthenticated')
    end
  end

  context 'inactive user' do
    should 'should return a warning if login with an inactive account' do
      user = create(:user, active: false)
      visit new_user_session_path

      assert_not user.active_for_authentication?
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_on I18n.t('views.session.new.submit')

      assert_current_path(new_user_session_path)
      assert_selector 'div.alert.alert-warning', text: I18n.t('devise.failure.inactive')

      visit users_root_path
      assert_selector 'div.alert.alert-warning', text: I18n.t('devise.failure.unauthenticated')
    end
  end
end
