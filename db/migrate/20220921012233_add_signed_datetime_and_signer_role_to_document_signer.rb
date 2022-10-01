class AddSignedDatetimeAndSignerRoleToDocumentSigner < ActiveRecord::Migration[6.0]
  def change
    change_table :document_signers, bulk: true do |t|
      t.column :signed_datetime, :datetime, null: true
      t.column :signer_role, :string, null: true
    end
  end
end
