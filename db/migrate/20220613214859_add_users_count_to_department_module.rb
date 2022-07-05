class AddUsersCountToDepartmentModule < ActiveRecord::Migration[6.0]
  def change
    add_column :department_modules, :department_module_users_count, :integer, default: 0, null: false

    DepartmentModule.find_each do |dep_module|
      DepartmentModule.reset_counters(dep_module.id, :department_module_users)
    end
  end
end
