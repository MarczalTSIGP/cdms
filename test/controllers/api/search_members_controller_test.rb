require 'test_helper'

class Api::SearchMembersControllerTest < ActionDispatch::IntegrationTest
  context 'autenticated' do
    setup do
      @module = create(:department_module)
      @department = @module.department
      @user = create(:user)
      @logged_user = create(:user, :manager)

      sign_in @logged_user
    end

    should 'search_department_non_members' do
      user = create(:user)
      get api_search_non_members_path(@department, nil, user.name)

      jresponse = JSON.parse(response.body)
      assert_equal [user.as_json(only: [:id, :name])], jresponse
    end

    should 'search_department_module_non_members' do
      user = create(:user)
      get api_search_non_members_path(@department, @module, user.name)

      jresponse = JSON.parse(response.body)
      assert_equal [user.as_json(only: [:id, :name])], jresponse
    end

    should 'search_department_not_return_member' do
      department_user = create(:department_user, :collaborator, department: @department)
      name = department_user.user.name

      get api_search_non_members_path(@department, nil, name)

      jresponse = JSON.parse(response.body)
      assert_not_equal [department_user.user.as_json(only: [:id, :name])], jresponse
    end

    should 'search_department_module_not_return_member' do
      module_user = create(:department_module_user, department_module: @module, role: :collaborator)
      name = module_user.user.name

      get api_search_non_members_path(@department, @module, name)

      jresponse = JSON.parse(response.body)
      assert_not_equal [module_user.user.as_json(only: [:id, :name])], jresponse
    end

    should 'search_non_document_users' do
      @document = create(:document, :certification, department: @department)

      get api_search_non_document_users_path(@document)

      jresponse = JSON.parse(response.body)
      assert_equal [@user.as_json(only: [:id, :name, :cpf]), @logged_user.as_json(only: [:id, :name, :cpf])], jresponse
    end
  end

  context 'unauthenticated' do
    should 'redirect_to_login' do
      get api_search_non_members_path(1)

      assert_redirected_to new_user_session_path
    end

    should 'redirect_to_login by not permission' do
      get api_search_non_document_users_path(1)

      assert_redirected_to new_user_session_path
    end
  end
end
