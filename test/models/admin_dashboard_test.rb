require 'test_helper'

class AdminDashboarTest < ActiveSupport::TestCase
  context '.departments' do
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

  context '.active_users' do
    setup do
      create(:user, active: true)
    end

    should 'return number of active users' do
      assert_equal 1, AdminDashboard.active_users.count
    end

    should 'return translation of active users in singular' do
      human = User.model_name.human(count: 1)
      human += " #{User.human_attribute_name(:active, count: 1)}"

      assert_equal human, AdminDashboard.active_users.human
    end

    should 'return translation of active users in plural' do
      create(:user, active: true)

      human = User.model_name.human(count: 2)
      human += " #{User.human_attribute_name(:active, count: 2)}"

      assert_equal human, AdminDashboard.active_users.human
    end
  end

  context '.inactive_users' do
    setup do
      create(:user, active: false)
    end

    should 'return number of inactive users' do
      assert_equal 1, AdminDashboard.inactive_users.count
    end

    should 'return translation of inactive users in singular' do
      human = User.model_name.human(count: 1)
      human += " #{User.human_attribute_name(:inactive, count: 1)}"

      assert_equal human, AdminDashboard.inactive_users.human
    end

    should 'return translation of inactive users in plural' do
      create(:user, active: false)

      human = User.model_name.human(count: 2)
      human += " #{User.human_attribute_name(:inactive, count: 2)}"
      assert_equal human, AdminDashboard.inactive_users.human
    end
  end

  context '.audience_members' do
    setup do
      create(:audience_member)
    end

    should 'return number of audience members' do
      assert_equal 1, AdminDashboard.audience_members.count
    end

    should 'return translation of audience members in singular' do
      assert_equal AudienceMember.model_name.human(count: 1), AdminDashboard.audience_members.human
    end

    should 'return translation of audience members in plural' do
      create(:audience_member)
      assert_equal AudienceMember.model_name.human(count: 2), AdminDashboard.audience_members.human
    end
  end

  context '.counters' do
    should 'return all counters' do
      assert_equal 4, AdminDashboard.counters.size
    end
  end
end
