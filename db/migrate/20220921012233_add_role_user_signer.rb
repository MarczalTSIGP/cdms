class AddRoleUserSigner < ActiveRecord::Migration[6.0]
  def change
    change_table :document_signers, bulk: true do |t|
      t.column :date_hour, :datetime, null: true
      t.column :role_user_signed, :string, null: true
    end
  end
end
