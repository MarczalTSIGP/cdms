require 'test_helper'

class DepartmentMembersTest < ActionController::TestCase
  setup do 
    Rails.application.routes.draw do
      get '/members', to: 'department_members#members', as: :member_test

      post '/members-tests', to: 'department_members#add_member', as: :add_member_test
      delete '/members-tests/:id', to: 'department_members#remove_member', as: :remove_member_test
      # resources :department_members
    end
    @controller = DepartmentMembersController.new
  end

  teardown do 
    Rails.application.reload_routes!
  end

  should "get members" do
    get :members

    assert_response :success
  end
  
end

class DepartmentMembersController < ActionController::Base
  include DepartmentMembers

  def set_department_member_members
    @department_member_user = DepartmentMemberUser.new
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