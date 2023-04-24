require 'csv'

class CreateDocumentRecipientsFromCsv
  def initialize(params = {})
    @file = params[:file]

    @valids = []
    @invalids = []
    @duplicates = []
    # @registered = []
    # @already_registered = []
    @document_id = params[:document_id]

    @attributes = [] # THIS ARRAY CONTAINS ALL VALID MEMBERS (ONLY ATTRIBUTES)
    @document_recipients_registered = []
  end

  def perform
    if valid_file?
      load_members # load the members from the csv file
      save_members # save the audience members
      # DO THE SAME THING OF CREATE_AUDIENCE_MEMBER_FROM_CSV SERVICE. THAN.
      assign_audiance_members_to_document(@document_id) # assign the members to the document
    end
    result
  end

  private

  def load_members
    CSV.foreach(@file, headers: true) do |row|
      attributes = row.to_h # keys: name, email, cpf.
      member = AudienceMember.new(attributes)

      next if add_to_save(member, attributes)

      if registered?(member)
        # @already_registered << member
        @attributes << attributes
      else
        @invalids << member
      end
    end
  end

  def valid_file?
    !@file.nil? && File.extname(@file) == '.csv'
  end

  def add_to_save(member, attributes)
    return false unless member.valid?

    if included?(member)
      @duplicates << member
    else
      # @registered << member
      @valids << attributes
      @attributes << attributes
    end
    true
  end

  def included?(member)
    @valids.detect do |register|
      register['cpf'].eql?(member.cpf) or register['email'].eql?(member.email)
    end
  end

  def registered?(member)
    details = member.errors.details
    cpf_taken = details[:cpf].pluck(:error).include?(:taken)
    email_taken = details[:email].pluck(:error).include?(:taken)

    cpf_taken or email_taken
  end

  def save_members
    AudienceMember.create!(@valids)
  end

  def assign_audiance_members_to_document(document_id)
    @attributes.each do |member|
      profile_type = if user?(member['cpf'])
                       ['User', profile_id = User.find_by(cpf: member['cpf']).id]
                     else
                       ['AudienceMember', profile_id = AudienceMember.find_by(cpf: member['cpf']).id]
                     end

      document_recipient = create_document_recipient(document_id, member['cpf'], profile_type, profile_id)
      @document_recipients_registered << document_recipient
    end
  end

  def create_document_recipient(document_id, cpf, profile_type, profile_id)
    DocumentRecipient.create(
      document_id: document_id,
      cpf: cpf,
      profile_type: profile_type,
      profile_id: profile_id
    )
  end

  def user?(cpf)
    User.exists?(cpf: cpf)
  end

  def result
    struct_result.new(document_recipients_registered: @document_recipients_registered,
                      invalids: @invalids + @duplicates,
                      valid_file?: valid_file?)
  end

  def struct_result
    @struct_result ||= Struct.new(:document_recipients_registered, :invalids, :valid_file?)
  end
end
