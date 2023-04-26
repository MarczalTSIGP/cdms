class DocumentRecipient < ApplicationRecord
  belongs_to :document
  belongs_to :profile, polymorphic: true

  validates :cpf, uniqueness: { scope: :document_id, case_sensite: false }

  def self.from_csv(file, document_id)
    CreateDocumentRecipientsFromCsv.new({ file: file, document_id: document_id }).perform
  end

  # def self.download_csv(document_id)
  #   return false unless Document.exists?(document_id)

  #   document = Document.find(document_id)
  #   document_variables = document.variables

  #   header = %w[name email cpf] # default values for the CSV

  #   document_variables.each do |variable|
  #     header << variable['name']
  #   end

  #   csv_data = CSV.generate(headers: true) do |csv|
  #     csv << header

  #     DocumentRecipient.where(document_id: document_id).each do |recipient|
  #       csv << recipient.to_csv
  #     end
  #   end

  #   csv_data
  # end
end
