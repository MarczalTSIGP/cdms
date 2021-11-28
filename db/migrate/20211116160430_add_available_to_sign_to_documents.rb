class AddAvailableToSignToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :available_to_sign, :boolean, default: false
  end
end
