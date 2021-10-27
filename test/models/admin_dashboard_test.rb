require 'test_helper'

class AdminDashboarTest < ActiveSupport::TestCase
  context 'departments' do
    should 'return number of departments' do
      assert_equal 0, AdminDashboard.departments.count

      create(:department)
      assert_equal 1, AdminDashboard.departments.count
    end

    should 'return translation fo department in singular' do
      create(:department)
      assert_equal Department.model_name.human(count: 1), AdminDashboard.departments.human
    end

    should 'return translation fo department in plural' do
      create_list(:department, 2)
      assert_equal Department.model_name.human(count: 2), AdminDashboard.departments.human
    end
  end

  context 'active users' do
    should 'return number of active users' do
      assert_equal 0, AdminDashboard.active_users.count
      create(:user, active: true)
      assert_equal 1, AdminDashboard.active_users.count
    end

    should 'return translation of active users in singular' do
      create(:user, active: true)
      assert_equal User.model_name.human(count: 1), AdminDashboard.active_users.human
    end

    should 'return translation of active users in plural' do
      create_list(:user, 2, active: true)
      assert_equal User.model_name.human(count: 2), AdminDashboard.active_users.human
    end
  end

  context 'inactive users' do
    should 'return number of inactive users' do
      assert_equal 0, AdminDashboard.inactive_users.count
      create(:user, active: false)
      assert_equal 1, AdminDashboard.inactive_users.count
    end

    should 'return translation of inactive users in singular' do
      create(:user, active: false)
      assert_equal User.model_name.human(count: 1), AdminDashboard.inactive_users.human
    end

    should 'return translation of inactive users in plural' do
      create_list(:user, 2, active: false)
      assert_equal User.model_name.human(count: 2), AdminDashboard.inactive_users.human
    end
  end

  context 'audience members' do
    should 'return number of audience members' do
      assert_equal 0, AdminDashboard.audience_members.count
      create(:audience_member)
      assert_equal 1, AdminDashboard.audience_members.count
    end

    should 'return translation of audience members in singular' do
      create(:audience_member)
      assert_equal AudienceMember.model_name.human(count: 1), AdminDashboard.audience_members.human
    end

    should 'return translation of audience members in plural' do
      create_list(:audience_member, 2)
      assert_equal AudienceMember.model_name.human(count: 2), AdminDashboard.audience_members.human
    end
  end
end
