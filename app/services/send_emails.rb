class SendEmails

	def initialize (params={})
    @signers
	end
	
  def perform
	  search_for_recipients
    send
  end

	private

	def send
		@signers.each do |sign|
			NotifyDocumentToSignMailer.with(user_id: sign.user_id, document_id: sign.document_id).notify_sign.deliver_later
		end
	end 

	def search_for_recipients
		@signers = DocumentSigner.where("signed = ?", false)
	end 
end