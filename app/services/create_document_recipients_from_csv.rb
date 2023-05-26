require 'csv'

class CreateDocumentRecipientsFromCsv < CreateFromCsv
  def initialize(params = {})
    super(params)
    @document = Document.find(params[:document_id])
  end

  def validates_presence_of_headers
    header = %w[name email cpf]
    header + @document.variables.pluck('identifier')
  end

  def load_registers
    registers do |attributes|
      cpf = attributes[:cpf]
      variables = variables(attributes)

      next if recipient_already_linked?(cpf)
      next if add_recipient_already_registered(cpf, variables)

      create_audience_member(attributes, variables)
    end
  end

  def save_registers; end

  private

  def variables(attributes)
    dv = @document.variables.pluck('identifier').map(&:to_sym)
    attributes.slice(*dv)
  end

  # Check if the recipient is already in document
  def recipient_already_linked?(cpf)
    recipient = @document.recipients.find_by(cpf: cpf)
    @already_registered << recipient if recipient

    recipient
  end

  # Add a recipient already registered in the document
  # Can be an user or AudienceMember
  def add_recipient_already_registered(cpf, variables)
    return false unless @document.recipients.add(cpf)

    recipient = @document.recipients.find_by(cpf: cpf)
    recipient.update(variables: variables)

    @registered << recipient
  end

  # Create new AudienceMember and link with the document
  def create_audience_member(attributes, variables)
    data = { name: attributes[:name], email: attributes[:email], cpf: attributes[:cpf] }
    am = AudienceMember.new(data)

    if am.save
      @document.recipients.add(am.cpf)
      recipient = @document.recipients.find_by(cpf: am.cpf)
      recipient.update(variables: variables)
      @registered << recipient
    else
      @invalids << am
    end
  end
end
