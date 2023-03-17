class CreateDepartmentModuleUsers < ActiveRecord::Migration[6.0]
  def change
    create_enum :department_module_users_roles, %w[responsible collaborator]

    create_table :department_module_users do |t|
      t.references :department_module, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.enum :role, enum_type: :department_module_users_roles

      t.timestamps
    end

    add_index :department_module_users, [:department_module_id, :user_id], unique: true, name: 'module_users'
    add_index :department_module_users, :role
  end
end
