class Logics::Document::Recipient
  def initialize(document_recipients)
    @document_recipients = document_recipients
  end

  def all
    @document_recipients.includes(:profile)
  end

  def add(cpf)
    recipient = self.class.find_by(cpf: cpf)
    return false if recipient.nil?

    data = {
      cpf: recipient.cpf,
      profile_id: recipient.id,
      profile_type: recipient.class.name
    }

    @document_recipients.new(data).save
  end

  def remove(cpf)
    document_recipient = @document_recipients.find_by(cpf: cpf)
    document_recipient&.destroy
  end

  def self.find_by(conditions)
    cpf = conditions[:cpf]

    user = User.find_by(cpf: cpf)
    return user if user.present?

    AudienceMember.find_by(cpf: cpf)
  end
end
