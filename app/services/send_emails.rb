class SendEmails

	def initialize (params={})
    @signers
    @sign_document = []
	end
	
  def perform
	  search_for_recipients
    send
  end

	private

	def send
		@signers.each do |document_sign|
      document_sign.each do |sign|
        @sign_document[] = 
      end
			NotifyDocumentToSignMailer.with(user_id: sign.user_id, document_id: sign.document_id).notify_sign.deliver_now
		end
	end 

	def search_for_recipients
		# @signers = DocumentSigner.where("signed = ?", false)
    @signers = DocumentSigner.where(signed: false).group_by(&:document_id)
	end 
end