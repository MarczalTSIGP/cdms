class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :username, index: { unique: true }
      t.string :register_number
      t.string :cpf, index: { unique: true }
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
