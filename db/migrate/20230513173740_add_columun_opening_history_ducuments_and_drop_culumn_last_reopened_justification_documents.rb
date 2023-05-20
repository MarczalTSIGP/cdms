class AddColumunOpeningHistoryDucumentsAndDropCulumnLastReopenedJustificationDocuments < ActiveRecord::Migration[6.1]
  def change
    remove_column :documents, :justification, :string
    remove_column :documents, :last_reopened_at, :datetime
    remove_column :documents, :last_reopened_by_user_id, :bigint
    add_column :documents, :opening_history, :jsonb, null: false, default: []
    add_index  :documents, :opening_history, using: :gin
  end
end
