require 'test_helper'

class Users::DashboardControllerTest < ActionDispatch::IntegrationTest
  context 'not logged in' do
    should 'redirect to sing_in' do
      get users_root_url

      assert_response :redirect
      assert_redirected_to new_user_session_url
    end
  end

  context 'logged in' do
    should 'get user dashboard' do
      user_sign = create(:user)
      sign_in user_sign

      get users_root_url

      assert_response :success
      assert_breadcrumbs({ text: I18n.t('views.breadcrumbs.home') })
      assert_active_link(href: users_root_path)
    end
  end
end
