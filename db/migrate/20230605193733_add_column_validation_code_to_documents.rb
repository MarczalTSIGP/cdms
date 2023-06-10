class AddColumnValidationCodeToDocuments < ActiveRecord::Migration[6.1]
  def change 
    add_column :documents, :verification_code, :string
    add_index :documents, :verification_code, using: :btree
  end
end
