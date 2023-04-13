class RemoveColumnFromDocuments < ActiveRecord::Migration[6.1]
  def change
    remove_column :documents, :back_text
  end
end
