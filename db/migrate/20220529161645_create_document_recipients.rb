class CreateDocumentRecipients < ActiveRecord::Migration[6.0]
  def change
    create_table :document_recipients do |t|
      t.references :document, null: false, foreign_key: true
      t.string :cpf, null: false
      t.references :profile, null: false, polymorphic: true

      t.timestamps
    end
  end
end
