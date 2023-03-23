require 'test_helper'

class AdminDashboarTest < ActiveSupport::TestCase
  context '.departments' do
    should 'return number of departments' do
      assert_equal 0, AdminDashboard.departments.amount

      create(:department)

      assert_equal 1, AdminDashboard.departments.amount
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
      assert_equal 1, AdminDashboard.active_users.amount
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
      assert_equal 1, AdminDashboard.inactive_users.amount
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
      assert_equal 1, AdminDashboard.audience_members.amount
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

  context '.cache' do
    should 'return cache_key departaments' do
      assert_equal "#{Department.model_name.human}-#{Department.count}", AdminDashboard.departments.cache_key
    end

    should 'return cache_key inactive users' do
      create(:user, active: true)

      human = User.model_name.human(count: 1)
      human += " #{User.human_attribute_name(:active, count: 1)}"

      assert_equal "#{human}-#{User.count}", AdminDashboard.active_users.cache_key
    end

    should 'return cache_key active users' do
      create(:user, active: false)

      human = User.model_name.human(count: 1)
      human += " #{User.human_attribute_name(:inactive, count: 1)}"

      assert_equal "#{human}-#{User.count}", AdminDashboard.inactive_users.cache_key
    end

    should 'return cache_key audience members' do
      key = AdminDashboard.audience_members.cache_key

      assert_equal "#{AudienceMember.model_name.human}-#{AudienceMember.count}", key
    end
  end
end
