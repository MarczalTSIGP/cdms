class AddMemberToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :members, :json, default: [] 
  end
end
