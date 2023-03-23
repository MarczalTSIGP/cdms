require 'test_helper'

class Admins::UsersControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      sign_in create(:user, :manager)
    end

    should 'get index' do
      get admins_users_path

      assert_response :success
      assert_active_link(href: admins_users_path)
    end

    should 'get new' do
      get new_admins_user_path

      assert_response :success
      assert_active_link(href: admins_users_path)
    end

    should 'get show' do
      get admins_user_path(@user)

      assert_response :success
      assert_active_link(href: admins_users_path)
    end

    should 'get edit' do
      get edit_admins_user_path(@user)

      assert_response :success
      assert_active_link(href: admins_users_path)
    end

    context '#create' do
      should 'successfully' do
        assert_difference('User.count', 1) do
          post admins_users_path, params: { user: attributes_for(:user) }
        end
        assert_redirected_to admins_users_path
        assert_equal I18n.t('flash.actions.create.m', resource_name: User.model_name.human),
                     flash[:success]
      end

      should 'unsuccessfully' do
        assert_no_difference('User.count') do
          post admins_users_path, params: { user: attributes_for(:user, username: '') }
        end

        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]
      end
    end

    context '#update' do
      should 'successfully' do
        patch admins_user_path(@user), params: { user: { name: 'updated' } }

        assert_redirected_to admins_users_path
        assert_equal I18n.t('flash.actions.update.m', resource_name: User.model_name.human),
                     flash[:success]
        @user.reload

        assert_equal 'updated', @user.name
      end

      should 'unsuccessfully' do
        patch admins_user_path(@user), params: { user: { name: '' } }

        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]

        name = @user.name
        @user.reload

        assert_equal name, @user.name
      end
    end

    should 'destroy' do
      assert_difference('User.count', -1) do
        delete admins_user_path(@user)
      end
      assert_redirected_to admins_users_path
    end
  end

  context 'unauthenticated' do
    should 'redirect to login when not authenticated' do
      assert_redirect_to(new_user_session_path)
    end

    should 'redirect to login when logged as non administrator user' do
      sign_in create(:user)

      assert_redirect_to(users_root_path)
    end
  end

  private

  def assert_redirect_to(redirect_to)
    requests.each do |method, routes|
      routes.each do |route|
        send(method, route)

        assert_redirected_to redirect_to
      end
    end
  end

  def requests
    {
      get: [admins_users_path, admins_users_path,
            edit_admins_user_path(1), admins_user_path(1)],
      post: [admins_users_path],
      patch: [admins_user_path(1)],
      delete: [admins_user_path(1)]
    }
  end
end
