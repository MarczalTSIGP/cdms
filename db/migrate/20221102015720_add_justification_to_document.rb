class AddJustificationToDocument < ActiveRecord::Migration[6.0]
  def change
    change_table :documents, bulk: true do |t|
      t.column :reopened, :boolean, default: false
      t.column :justification, :string, null: true
      t.column :created_by, :string, null: true
      t.column :edited_by, :string, null: true
      t.column :date_edition, :datetime, null: true
    end
  end
end
