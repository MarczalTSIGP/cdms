class AddColumnUsersToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :users, :json, default: []
  end
end
