require 'test_helper'

class Admins::DashboardControllerTest < ActionDispatch::IntegrationTest
  context 'not logged in' do
    should 'redirect to sing_in' do
      get admins_root_url

      assert_response :redirect
      assert_redirected_to new_user_session_url
    end

    should 'redirect to users_root_path' do
      sign_in create(:user)
      get admins_root_url

      assert_response :redirect
      assert_redirected_to users_root_path
    end
  end

  context 'logged in' do
    should 'get admin dashboard' do
      role = create(:role_manager)
      @user = create(:user)
      user_sign = create(:user)
      user_sign.role = role
      sign_in user_sign

      get admins_root_url

      assert_response :success
      assert_breadcrumbs({ text: I18n.t('views.breadcrumbs.home') })
      assert_active_link(href: admins_root_path)
    end
  end
end
