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
end
