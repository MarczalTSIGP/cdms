# Preview all emails at http://localhost:3000/rails/mailers/notify_document_to_sign_mailer
class NotifyDocumentToSignMailerPreview < ActionMailer::Preview
    def notify_sign
        NotifyDocumentToSignMailer.notify_sign()
    end
end
