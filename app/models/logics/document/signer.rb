class Logics::Document::Signer 
  def search_for_recipients
    return signers = DocumentSigner.where(signed: false).group_by(&:document_id)
  end 
    
  def get_emails(params = {})
    return emails = params[:document_signers].map {|signer_mail| User.find(signer_mail.user_id).email}
  end
end