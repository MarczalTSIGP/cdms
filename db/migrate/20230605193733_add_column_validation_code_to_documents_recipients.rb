class AddColumnValidationCodeToDocumentsRecipients < ActiveRecord::Migration[6.1]
  def change 
    add_column :document_recipients, :qr_code_base, :string
    add_column :document_recipients, :verification_code, :string
    add_index :document_recipients, :verification_code, using: :btree
  end
end
