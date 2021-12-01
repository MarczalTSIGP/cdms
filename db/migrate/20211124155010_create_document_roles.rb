class CreateDocumentRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :document_roles do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
    add_index :document_roles, :name, unique: true
  end
end
