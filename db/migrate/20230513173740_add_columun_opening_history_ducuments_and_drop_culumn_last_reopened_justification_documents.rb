class AddColumunOpeningHistoryDucumentsAndDropCulumnLastReopenedJustificationDocuments < ActiveRecord::Migration[6.1]
  def up
    change_table :documents, bulk: true do |t|
      t.remove :justification
      t.remove :last_reopened_at
      t.remove :last_reopened_by_user_id
      t.jsonb :opening_history, null: false, default: []
      t.index :opening_history, using: :gin
    end
  end

  def down
    change_table :documents, bulk: true do |t|
      t.column :justification, :string
      t.column :last_reopened_at, :datetime
      t.column :last_reopened_by_user_id, :bigint
      t.remove :opening_history
    end
  end
end
