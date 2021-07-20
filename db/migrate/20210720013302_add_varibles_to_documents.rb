class AddVariblesToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :variables, :json, default: []
  end
end
