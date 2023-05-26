require 'csv'

<<<<<<< HEAD
class CreateDocumentRecipientsFromCsv < CreateAudienceMembersFromCsv
  def initialize(params = {})
    @document_id = params[:document_id]
    @attributes = [] # THIS ARRAY CONTAINS ALL VALID MEMBERS (ONLY ATTRIBUTES)
    @invalid_attributes = [] # THIS ARRAY CONTAINS ALL INVALID MEMBERS (ONLY ATTRIBUTES)
    @document_recipients_registered = []
    super
  end

  def perform
    if valid_file?
      load_members # load the members from the csv file
      save_members # save the audience members
      # DO THE SAME THING OF CREATE_AUDIENCE_MEMBER_FROM_CSV SERVICE. THAN.
      assign_document_recipients_to_document(@document_id) # assign the members to the document
    end
    result
  end

  private

  def load_members
    CSV.foreach(@file, headers: true) do |row|
      attributes = row.to_h # keys: name, email, cpf, and custom variables from document
      member = AudienceMember.new(name: attributes['name'], email: attributes['email'], cpf: attributes['cpf'])

      next if add_to_save(member, attributes)

      if registered?(member)
        [@already_registered << member, @attributes << attributes]
      else
        [@invalids << member, @invalid_attributes << attributes]
      end
    end
  end

  def add_to_save(member, attributes)
    return false unless member.valid?

    if included?(member)
      [@duplicates << member, @invalid_attributes << attributes]
    else
      [@registered << member, @valids << attributes, @attributes << attributes]
    end
    true
  end

  def assign_document_recipients_to_document(document_id)
    @attributes.each do |member|
      if user?(member['cpf'])
        [member['profile_type'] = 'User', member['profile_id'] = User.find_by(cpf: member['cpf']).id]
      else
        [member['profile_type'] = 'AudienceMember',
         member['profile_id'] = AudienceMember.find_by(cpf: member['cpf']).id]
      end

      document_recipient = create_document_recipient(member, document_id)
      @document_recipients_registered << document_recipient
    end
  end

  def create_document_recipient(member, document_id)
    custom_variables = member.except('name', 'email', 'cpf', 'profile_type', 'profile_id')

    DocumentRecipient.create!(
      document_id: document_id,
      cpf: member['cpf'],
      profile_type: member['profile_type'],
      profile_id: member['profile_id'],
      variables: JSON.parse(custom_variables.to_json)
    )
  end

  def user?(cpf)
    User.exists?(cpf: cpf)
  end

  def result
    struct_result.new(document_recipients_registered: @document_recipients_registered,
                      invalids: @invalid_attributes,
                      valid_file?: valid_file?)
  end

  def struct_result
    @struct_result ||= Struct.new(:document_recipients_registered, :invalids, :valid_file?)
=======
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
>>>>>>> Review-PR-85
  end
end
