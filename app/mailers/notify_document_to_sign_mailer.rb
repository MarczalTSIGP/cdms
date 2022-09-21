class NotifyDocumentToSignMailer < ApplicationMailer
    def notify_sign
        @document = params[:document]
        @signer = User.find(params[:user_id])  
        mail(to: @signer.email, subject: t('devise.mailer.notify_sign.action'))
    end
end
