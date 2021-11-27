require 'test_helper'

class Admins::PagesControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      sign_in create(:user, :manager)

      @page = create(:page, url: 'about')
    end

    should 'get edit about page' do
      get admins_edit_about_page_path
      assert_response :success
    end

    context '#update' do
      should 'successfully' do
        post admins_edit_about_page_path(@page), params: { page: { content: 'updated' } }
        assert_redirected_to admins_edit_about_page_path
        assert_equal I18n.t('flash.actions.update.m', resource_name: Page.model_name.human), flash[:success]
        @page.reload
        assert_equal 'updated', @page.content
        follow_redirect!
      end

      should 'unsuccessfully' do
        post admins_edit_about_page_path(@page), params: { page: { content: '' } }
        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]

        content = @page.content
        @page.reload
        assert_equal content, @page.content
      end
    end
  end

  context 'unauthenticated' do
    should 'redirect to sing_in' do
      get admins_edit_about_page_path
      assert_response :redirect
      assert_redirected_to new_user_session_url
    end

    should 'redirect to users_root_path' do
      sign_in create(:user)
      get admins_edit_about_page_path
      assert_response :redirect
      assert_redirected_to users_root_url
    end
  end
end
