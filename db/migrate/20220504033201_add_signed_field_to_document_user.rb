class AddSignedFieldToDocumentUser < ActiveRecord::Migration[6.0]
  def change
    add_column :document_users, :signed, :boolean, default: false
  end
end
