class ChangeTableNameToDocumentSigner < ActiveRecord::Migration[6.0]
  def change
    rename_table :document_users, :document_signers
  end
end
