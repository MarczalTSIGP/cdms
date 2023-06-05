class AddColumnValidationCodeToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :verification_code, :string   
  end
end


#adicionar index, 