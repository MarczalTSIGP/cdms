class Users::DocumentRecipientsController < Users::BaseController
  before_action :set_document

  include Users::Breadcrumbs::DocumentRecipients

  def index
    @document_recipients = @document.recipients.all
  end

  def new
    return unless (cpf = params[:cpf])

    @document_recipient = DocumentRecipient.find_by(cpf: cpf, document_id: @document.id)

    if @document_recipient
      flash.now[:warning] = I18n.t('flash.actions.add.errors.exists',
                                   resource_name: I18n.t('views.document.recipients.name'))
    else
      @recipient = Logics::Document::Recipient.find_by(cpf: cpf)
      flash.now[:warning] = I18n.t('flash.not_found') unless @recipient
    end
  end

  def add_recipient
    if @document.recipients.add(params[:cpf])
      flash['success'] = I18n.t('flash.actions.add.m', resource_name: I18n.t('views.document.recipients.name'))
    else
      flash['error'] = I18n.t('flash.actions.add.errors.not')
    end

    redirect_to users_document_recipients_path
  end

  def remove_recipient
    if @document.recipients.remove(params[:cpf])
      flash['success'] = I18n.t('flash.actions.destroy.m',
                                resource_name: I18n.t('views.document.recipients.name'))
    else
      flash['error'] = I18n.t('flash.not_found')
    end

    redirect_to users_document_recipients_path
  end

  private

  def set_document
    @document = Document.find_by(id: params[:id])
    if @document.document_already_signed(@document.id)
      flash[:warning] = t('flash.actions.add_recipients.non')
      redirect_to users_documents_path
    else
      @document.blank?
    end
  end
end
