require 'test_helper'

class DepartmentMembersTest < ActionController::TestCase
  setup do
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get '/members', to: 'department_members#members', as: :member_test
      post '/members', to: 'department_members#add_member', as: :add_member_test
      delete '/members/:id', to: 'department_members#remove_member', as: :remove_member_test
    end

    @controller = DepartmentMembersController.new
  end

  teardown do
    Rails.application.routes.disable_clear_and_finalize = false
    Rails.application.reload_routes!
  end

  should 'get members' do
    # disable render view
    def @controller.default_render
      :ok
    end

    get :members

    assert_response :success
  end

  should 'add members' do
    params = { user_id: 1, department_id: 1, role: :collaborator }
    @request.headers['HTTP_REFERER'] = 'http://test.host/members'

    post :add_member, params: { member: params }

    assert_redirected_to add_member_test_path
  end

  should 'not add members' do
    # disable render view
    def @controller.render(_params)
      :ok
    end
    params = { user_id: 2, role: :collaborator }

    post :add_member, params: { member: params }

    assert_response :success
  end

  should 'remove members' do
    @request.headers['HTTP_REFERER'] = 'http://test.host/members'

    post :remove_member, params: { id: 1 }

    assert_redirected_to add_member_test_path
  end

  #   # ActionView::Renderer.any_instance.stubs(:render).returns('')
  #   mock = Minitest::Mock.new
  #   mock.expect :call, nil

  #   mockA = Minitest::Mock.new
  #   mockA.expect :call, nil

  #   # @controller.stub :default_render, :ok do
  #     @controller.stub :set_department_member_members, mockA do
  #     DepartmentMemberUser.stub :new, mock do
  #       get :members
  #     end
  #     end
  #   # end
  #
  #   assert_mock mock
  #   assert_mock mockA
  #   assert_response :success
  #  @controller.members
  #  p @controller.instance_variable_get('@department_member_user')
  # assert @controller.instance_variable_get('@user').instance_of?(DepartmentMemberUser)
end

class DepartmentMembersController < ActionController::Base
  include DepartmentMembers
  before_action :set_department_member

  def set_department_member
    @department_member = DepartmentMember.new
  end
end

class DepartmentMember
  extend ActiveModel::Naming

  def members
    []
  end

  def add_member(params)
    params[:user_id].eql?('1')
  end

  def remove_member(_params)
    true
  end

  def department_member_users
    []
  end

  def id
    1
  end

  def to_param
    id.to_s
  end
end

class DepartmentMemberUser
  extend ActiveModel::Naming
  def id
    1
  end

  def to_param
    id.to_s
  end
end
