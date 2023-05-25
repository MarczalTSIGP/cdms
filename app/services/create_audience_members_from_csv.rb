require 'csv'

class CreateAudienceMembersFromCsv < CreateFromCsv
  private

  def validates_presence_of_headers
    %w[name email cpf]
  end

  def load_registers
    registers do |attributes|
      member = AudienceMember.new(attributes)
      next if add_to_save(member, attributes)

      if registered?(member)
        @already_registered << member
      else
        @invalids << member
      end
    end
  end

  def save_registers
    AudienceMember.create!(@valids)
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

  def registered?(member)
    details = member.errors.details
    cpf_taken = details[:cpf].pluck(:error).include?(:taken)
    email_taken = details[:email].pluck(:error).include?(:taken)

    cpf_taken or email_taken
  end

  def included?(member)
    @valids.detect do |register|
      register[:cpf].eql?(member.cpf) or register[:email].eql?(member.email)
    end
  end
end
