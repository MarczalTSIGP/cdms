# Preview all emails at http://localhost:3000/rails/mailers/notify_document_to_sign_mailer
class NotifyDocumentToSignMailerPreview < ActionMailer::Preview
    def notify_sign
        @document = Document.last
        @signer = User.last
        NotifyDocumentToSignMailer.with(user_id: @signer.id, document: @document).notify_sign
    end
end
