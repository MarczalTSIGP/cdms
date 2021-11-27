class CreateDocumentUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :document_users do |t|
      t.references :document, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    add_index :document_users, [:document_id, :user_id], unique: true
  end
end
