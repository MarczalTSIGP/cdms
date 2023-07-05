class DocumentRecipient < ApplicationRecord
  belongs_to :document
  belongs_to :profile, polymorphic: true

  validates :cpf, uniqueness: { scope: :document_id, case_sensite: false }
  after_create :generate_qrcode

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

  private

  def generate_qrcode
    verification_code = Time.now.to_i + id
    url = Rails.application.routes.url_helpers.document_url(verification_code)
    qr_code = GenerateQrCode.new(url).perform

    update(qr_code_base: qr_code.base64, verification_code: verification_code)
  end
end
