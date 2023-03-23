class CreateDepartmentUsers < ActiveRecord::Migration[6.0]
  def change
    create_enum :department_users_roles, %w[responsible collaborator]

    create_table :department_users do |t|
      t.references :department, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.enum :role, enum_type: :department_users_roles

      t.timestamps
    end

    # execute <<-SQL
    #   CREATE TYPE department_users_roles AS ENUM ('responsible', 'collaborator');
    # SQL
    #
    # add_column :department_users, :role, :department_users_roles
    add_index :department_users, [:department_id, :user_id], unique: true
    add_index :department_users, :role
  end

  # def down
  # drop_table :department_users
  # execute <<-SQL
  #   DROP TYPE department_users_roles;
  # SQL
  # end
end
