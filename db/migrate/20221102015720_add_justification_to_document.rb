class AddJustificationToDocument < ActiveRecord::Migration[6.0]
  def change
    change_table :documents, bulk: true do |t|
      t.column :justification, :string, null: true
      t.references :creator_user, index: true, foreign_key: { to_table: :users }
      t.references :last_reopened_by_user, index: true, foreign_key: { to_table: :users }
      t.column :last_reopened_at, :datetime, null: true
      t.column :reopened, :boolean, default: false
    end
  end
end
