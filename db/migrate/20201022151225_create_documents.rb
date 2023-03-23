class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_enum :document_categories, %w[declaration certification]

    create_table :documents do |t|
      t.references :department, null: false, foreign_key: true
      t.enum :category, enum_type: :document_categories
      t.string :title, null: false
      t.text :front_text
      t.text :back_text

      t.timestamps
    end

    # execute <<-SQL
    #   CREATE TYPE document_categories AS ENUM ('declaration', 'certification');
    # SQL
    #
    # add_column :documents, :role, :document_categories
    add_index :documents, :category
  end

  # def down
  # drop_table :documents
  # execute <<-SQL
  #   DROP TYPE document_categories;
  # SQL
  # end
end
