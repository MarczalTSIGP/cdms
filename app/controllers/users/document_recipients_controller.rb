class Users::DocumentRecipientsController < Users::BaseController
  before_action :set_document
  before_action :set_breadcrumb_documents, only: [:index, :new]
  before_action :set_breadcrumb_document, only: [:index, :new]
  before_action :set_breadcrumb_index, only: [:index]
  before_action :set_breadcrumb_new, only: [:new]

  def index
    @document_recipients = @document.recipients
  end

  def new
    cpf = params[:cpf]
    @profile = search_non_recipient_document(cpf) if cpf.present?
  end

  def add_recipient
    cpf = params[:cpf]

    if @document.add_recipient(cpf)
      flash['success'] = I18n.t('flash.actions.add.m', resource_name: I18n.t('views.document.recipients.name'))
      return redirect_to users_document_recipients_path
    end

    flash.now['error'] = I18n.t('flash.actions.errors')
    render :new
  end

  def remove_recipient
    cpf = params[:cpf]

    if @document.remove_recipient(cpf)
      flash['success'] = I18n.t('flash.actions.destroy.m', resource_name: I18n.t('views.document.recipients.name'))
    end

    redirect_to users_document_recipients_path
  end

  private

  def search_non_recipient_document(cpf)
    non_recipient = @document.search_non_recipient(cpf)

    return registered_recipient if non_recipient == false

    return register_not_found if non_recipient.blank?

    @profile = non_recipient
  end

  def registered_recipient
    flash.now['warning'] = I18n.t('flash.actions.add.errors.existes',
                                  resource_name: I18n.t('views.document.recipients.name'))
    render :new
  end

  def register_not_found
    flash.now[:warning] = I18n.t('flash.not_found')
    render :new
  end

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
