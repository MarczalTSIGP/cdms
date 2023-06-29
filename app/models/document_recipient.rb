require_relative '../services/create_qrcode'
#require 'base64'

class DocumentRecipient < ApplicationRecord
  belongs_to :document
  belongs_to :profile, polymorphic: true

  validates :cpf, uniqueness: { scope: :document_id, case_sensite: false }
  after_create :generate_unique_code

  def self.from_csv(file, document_id)
    CreateDocumentRecipientsFromCsv.new({ file: file, document_id: document_id }).perform
  end

  def self.csv_model_file(document)
    return false unless document

    header = %w[name email cpf] # default values for the CSV
    header += document.variables.pluck('identifier')

    CSV.generate(headers: true) do |csv|
      csv << header
    end
  end

  def generate_unique_code
    update(verification_code: Time.now.to_i + id) if verification_code.blank?
    generate_qrcode_enc_base
  end

  def generate_qrcode_enc_base
    qr_code = CreateQrCode.new("http://localhost/documents", verification_code)
    base64_data = qr_code.generate_and_send_base64
    update(qr_code_base: base64_data)
  end
end
