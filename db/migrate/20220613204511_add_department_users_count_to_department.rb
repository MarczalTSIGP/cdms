class AddDepartmentUsersCountToDepartment < ActiveRecord::Migration[6.0]
  def change
    add_column :departments, :department_users_count, :integer, default: 0, null: false

    Department.find_each do |department|
      Department.reset_counters(department.id, :department_users)
    end
  end
end
