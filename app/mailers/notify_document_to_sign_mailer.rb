class NotifyDocumentToSignMailer < ApplicationMailer
    def notify_sign
        @document = params[:document]
        @recipient = User.find_by(cpf: params[:cpf])  
        if !@recipient 
            @recipient = AudienceMember.find_by(cpf: params[:cpf])
        end        
        mail(to: @recipient.email, subject: t('devise.mailer.notify_sign.action'))
    end
end
