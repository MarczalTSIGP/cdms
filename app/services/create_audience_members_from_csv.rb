require 'csv'

class CreateAudienceMembersFromCsv
  def initialize(params = {})
    @file = params[:file]

    @valids = []
    @invalids = []
    @duplicates = []
    @registered = []
    @already_registered = []
  end

  def perform
    if valid_file?
      load_members
      save_members
    end
    result
  end

  private

  def load_members
    CSV.foreach(@file, headers: true) do |row|
      attributes = row.to_h
      member = AudienceMember.new(attributes)

      next if add_to_save(member, attributes)

      if registered?(member)
        @already_registered << member
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
      @registered << member
      @valids << attributes
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

  def result
    struct_result.new(registered: @registered,
                      already_registered: @already_registered,
                      invalids: @invalids, duplicates: @duplicates,
                      valid_file?: valid_file?)
  end

  def struct_result
    @struct_result ||= Struct.new(:registered, :already_registered, :invalids, :duplicates, :valid_file?)
  end
end
