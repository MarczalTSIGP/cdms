class SendEmails
	def send
		search_for_recipients
		for signer in @signers do
			NotifyDocumentToSignMailer.with(signer: @signer).notify_sign.deliver_later
		end
	end 

	def search_for_recipients
		@signers = DocumentSigner.where("signed = ?", false).group("document")
	end 
end