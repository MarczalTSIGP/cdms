class AddRoleToDocumentUser < ActiveRecord::Migration[6.0]
  def change
    add_reference :document_users, :document_role, foreign_key: true
  end
end
