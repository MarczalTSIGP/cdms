class NotifyDocumentToSignMailer < ApplicationMailer
  def notify_sign
    @document = Document.find(params[:document_id])
    @emails = params[:emails]
    mail(to: @emails, subject: t('devise.mailer.notify_sign.action'))
  end
end
