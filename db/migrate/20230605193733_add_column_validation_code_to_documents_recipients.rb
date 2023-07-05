class AddColumnValidationCodeToDocumentsRecipients < ActiveRecord::Migration[6.1]
  def change
    change_table :document_recipients, bulk: true do |t|
      t.column :qr_code_base, :string
      t.column :verification_code, :string
      t.index :verification_code, using: :btree
    end
  end
end
