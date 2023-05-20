class Users::DocumentsController < Users::BaseController
  before_action :can_manager?, only: [:edit, :new, :update, :create, :destroy]
  before_action :set_document, except: [:index, :new, :create]
  before_action :set_departments, only: [:edit, :new, :update, :create]

  include Breadcrumbs

  def index
    @documents = current_user.documents.search(params[:term]).page(params[:page]).includes(:department)
  end

  def show; end

  def preview
    breadcrumb_name = I18n.t('views.document.preview', id: @document.id)
    add_breadcrumb breadcrumb_name, :users_preview_document_path
  end

  def new
    @document = Document.new
  end

  def edit
    if @document.someone_signed?
      set_flash_message_with_link_to_reopen
      redirect_to users_documents_path
    else
      render :edit
    end
  end

  def create
    @document = create_document
    @document.creator_user = current_user

    if @document.save
      success_create_message
      redirect_to users_documents_path
    else
      error_message
      render :new
    end
  end

  def update
    if @document.update(document_params)
      success_update_message
      redirect_to users_documents_path
    else
      error_message
      render :edit
    end
  end

  def destroy
    @document.destroy
    success_destroy_message
    redirect_to users_documents_path
  end

  def toggle_available_to_sign
    @document.toggle(:available_to_sign).save!
  end
  
  def reopen_to_edit
    if params[:document][:justification].strip.empty?
      flash[:error] = t('flash.actions.reopen_document.error')
      redirect_to users_documents_path
    else
      @document.reopen_to_edit(reopen_params)
      flash[:success] = t('flash.actions.reopen_document.success')
      redirect_to edit_users_document_path(@document)
    end
  end

  def opening_history
    if @document.opening_history.empty?
      flash[:error] = t('flash.actions.reopen_document.opening_history')
      redirect_to users_documents_path
    else
      add_breadcrumb I18n.t('views.document.links.opening_history', id: @document.id)
    end
  end

  private

  def user_params
    params.require(:document).permit(:justification)
  end

  def can_manager?
    return true if current_user.member_of_any?

    flash[:warning] = t('flash.actions.member.non')
    redirect_to users_documents_path
  end

  def set_document
    @document = Document.find(params[:id])
  end

  def set_departments
    @departments = current_user.departments
  end

  # only allow create a document to current user departments
  def create_document
    department_id = document_params[:department_id]
    return Document.new(document_params) if department_id.blank?

    department = current_user.departments.find(department_id)
    department.documents.create(document_params)
  end

  def document_params
    params.require(:document).permit(:title, :content, :category,
                                     :department_id, :variables, :available_to_sign)
  end

  def set_flash_message_with_link_to_reopen
    modal_id = "#modal_document_justification_#{@document.id}"
    link = view_context.link_to I18n.t('views.links.click_here'),
                                '#',
                                'data-toggle' => 'modal',
                                'data-target' => modal_id

    flash[:warning] = t('flash.actions.reopen_document.info', link: link)
  end

  def reopen_params
    { user_id: current_user.id, user_name: current_user.name, justification: params[:document][:justification] }
  end
end
