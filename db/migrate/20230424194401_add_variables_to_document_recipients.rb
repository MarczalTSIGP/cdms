class AddVariablesToDocumentRecipients < ActiveRecord::Migration[6.1]
  def change
    add_column :document_recipients, :variables, :json, default: []
  end
end
