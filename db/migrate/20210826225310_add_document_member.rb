class AddDocumentMember < ActiveRecord::Migration[6.0]
  def change
    create_table :document_members do |t|
      t.string :name, null: false
      t.string :email, index: { unique: true }, null: false
      t.string :cpf, index: { unique: true }, null: false
      t.timestamps
    end
  end
end
