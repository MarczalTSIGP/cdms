class AddActiveToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :active, :boolean, default: false
  end
end
