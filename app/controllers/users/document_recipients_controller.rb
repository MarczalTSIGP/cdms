class Users::DocumentRecipientsController < Users::BaseController
  before_action :set_document
  before_action :set_breadcrumb_documents, only: [:index, :new]
  before_action :set_breadcrumb_document, only: [:index, :new]
  before_action :set_breadcrumb_index, only: [:index]
  before_action :set_breadcrumb_new, only: [:new]

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
    redirect_to users_documents_path if @document.blank?
  end

  def set_breadcrumb_documents
    add_breadcrumb Document.model_name.human(count: 2), :users_documents_path
  end

  def set_breadcrumb_document
    add_breadcrumb I18n.t('views.breadcrumbs.show', model: Document.model_name.human, id: @document.id),
                   users_document_path(@document)
  end

  def set_breadcrumb_index
    add_breadcrumb I18n.t('views.document.recipients.plural')
  end

  def set_breadcrumb_new
    add_breadcrumb I18n.t('views.document.recipients.plural'), :users_document_recipients_path
    add_breadcrumb I18n.t('views.document.recipients.new')
  end
end
