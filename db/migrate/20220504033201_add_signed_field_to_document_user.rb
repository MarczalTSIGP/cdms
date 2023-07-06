class AddSignedFieldToDocumentUser < ActiveRecord::Migration[6.0]
  def change
    add_column :document_users, :signed, :boolean, null: false, default: false
  end
end
