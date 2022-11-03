class SendEmails

	def initialize(params={})
    @signers = Logics::Document::Signer.new
	end
	
  def perform
    send
  end

	private

  def send
		@signers.search_for_recipients.each do |document_id, document_signers|
      @emails = @signers.get_emails(document_signers: document_signers)
      send_email(document_id: document_id)
		end
	end

  def send_email(params = {})
    NotifyDocumentToSignMailer.with(emails: @emails , document_id: params[:document_id]).notify_sign.deliver_now
  end
end