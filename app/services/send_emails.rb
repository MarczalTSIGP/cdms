class SendEmails
  def self.perform
    send
  end

  def self.send
    dsu = DocumentSigner.unsigned
    dsu.group_by(&:document_id).each do |document_id, document_signers|
      emails = document_signers.map { |ds| "#{ds.user.name} <#{ds.user.email}>," }
      send_email(emails, document_id)
    end
  end

  def self.send_email(emails, document_id)
    NotifyDocumentToSignMailer
      .with(emails: emails, document_id: document_id)
      .notify_sign.deliver_now
  end
end
