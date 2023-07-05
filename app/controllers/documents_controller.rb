class DocumentsController < ApplicationController
  layout 'layouts/public/documents'

  def index
    return unless params[:document] && params[:document][:code]

    code = params[:document][:code]
    if code.present?
      redirect_to document_path(code)
    else
      flash[:warning] = I18n.t('views.documents.invalid_code')
      redirect_to documents_path
    end
  end

  def show
    @document_recipient = DocumentRecipient.find_by(verification_code: params[:code])

    if @document_recipient
      @document = @document_recipient.document
      flash[:success] = I18n.t('views.documents.valid_code', code: params[:code])
    else
      flash[:warning] = I18n.t('views.documents.not_exist_document', code: params[:code])
      redirect_to documents_path
    end
  end
end
