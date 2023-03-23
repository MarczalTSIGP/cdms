require 'test_helper'

class Admins::AdministratorsControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated_with_manager' do
    setup do
      @user = create(:user)
      sign_in create(:user, :manager)
    end

    should 'get index' do
      get admins_administrators_path

      assert_response :success
      assert_active_link(href: admins_administrators_path)
    end

    context '#create' do
      should 'successfully' do
        user = FactoryBot.create(:user)
        role = FactoryBot.create(:role_manager)

        params = { user: user.name, user_id: user.id, role_id: role.id }
        post admins_administrators_path, params: { administrator: params }

        user.reload

        assert user.is?(:admin)
        assert user.is?(:manager)
        assert_redirected_to admins_administrators_path
        assert_equal I18n.t('flash.actions.add.m', resource_name: Administrator.model_name.human), flash[:success]
      end

      should 'unsuccessfully' do
        params = { user: '', user_id: '', role_id: '' }
        post admins_administrators_path, params: { administrator: params }

        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]
      end
    end

    context '#destroy' do
      should 'successfully' do
        user = FactoryBot.create(:user, :assistant)
        delete admins_administrator_path(user)
        user.reload

        assert_not user.is?(:admin)
        assert_not user.is?(:assistant)
        assert_redirected_to admins_administrators_path
      end
    end
  end

  context 'authenticated_with_assistant' do
    setup do
      sign_in create(:user, :assistant)
    end

    context '#destroy' do
      should 'unsuccessfully' do
        user = FactoryBot.create(:user, :manager)
        delete admins_administrator_path(user)

        user.reload

        assert user.is?(:admin)
        assert user.is?(:manager)
        assert_redirected_to admins_administrators_path
        message = I18n.t('flash.actions.least', resource_name: Administrator.model_name.human)

        assert_equal message, flash[:warning]
      end
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
      get: [admins_administrators_path],
      post: [admins_administrators_path],
      delete: [admins_administrator_path(1)]
    }
  end
end
