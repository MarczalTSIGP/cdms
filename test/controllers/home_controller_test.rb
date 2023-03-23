require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  context 'public' do
    setup do
      @page = create(:page, url: 'about')
    end

    should 'get home' do
      get root_path

      assert_response :success
    end

    should 'get about' do
      get about_path

      assert_response :success
    end

    should 'get login' do
      get login_path

      assert_response :success
    end
  end
end
