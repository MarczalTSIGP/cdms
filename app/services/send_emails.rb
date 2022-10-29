class SendEmails

	def initialize(params={})
    @signers
	end
	
  def perform
	  search_for_recipients
    send
  end

	private

  def send
		@signers.each do |document_id, document_signers|
      @emails = []
      document_signers.each do |signer|
        add_email(user_id: signer.user_id)
      end
      send_email(document_id: document_id)
		end
	end

	def search_for_recipients
    @signers = DocumentSigner.where(signed: false).group_by(&:document_id)
	end 

  def add_email(params = {})
    user = User.find(params[:user_id])
    @emails.unshift(user.email) 
  end

  def send_email(params = {})
    NotifyDocumentToSignMailer.with(emails: @emails , document_id: params[:document_id]).notify_sign.deliver_now
  end
end