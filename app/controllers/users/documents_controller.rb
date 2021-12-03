class Users::DocumentsController < Users::BaseController
  before_action :can_manager?, only: [:edit, :new, :update, :create, :destroy]
  before_action :set_document, except: [:index, :new, :create, :remove_user]
  before_action :set_departments, only: [:edit, :new, :update, :create]
  include Breadcrumbs

  def index
    @documents = current_user.documents.search(params[:term]).page(params[:page]).includes(:department)
  end

  def show; end

  def preview
    render layout: 'users/document_preview'
  end

  def new
    @document = Document.new
  end

  def edit; end

  def create
    @document = create_document

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

  def users
    breadcrumbs_users
    @document_users = @document.users
    @document_receiver = DocumentReceiver.new
  end

  def add_user
    @document_receiver = DocumentReceiver.new(document_receiver_params)
    @document_receiver.document_id = @document.id

    if @document_receiver.save
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_to users_document_add_user_path(@document)
    else
      error_message
      @document_users = @document.users
      render :users
    end
  end

  def remove_user
    user_id = params[:id]
    document_id = params[:document_id]

    @document = Document.find(document_id)

    if @document.remove_user(user_id)
      flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)
      redirect_to users_document_add_user_path(@document)
    else
      error_message
      render :users
    end
  end

  private

  def can_manager?
    return true if current_user.member_of_any?

    flash[:warning] = t('flash.actions.member.non')
    redirect_to users_documents_path
  end

  def set_document
    @document = current_user.documents.find(params[:id])
  end

  def set_departments
    @departments = current_user.departments
  end

  def create_document
    if document_params[:department_id].present?
      department = current_user.departments.find(document_params[:department_id])
      department.documents.create(document_params)
    else
      Document.new(document_params)
    end
  end

  def document_params
    params.require(:document).permit(:title, :front_text, :back_text, :category,
                                     :department_id, :variables, :available_to_sign)
  end

  def document_receiver_params
    params.require(:document_receiver).permit(:user, :user_id)
  end

  def breadcrumbs_users
    add_breadcrumb I18n.t('views.breadcrumbs.show', model: Document.model_name.human, id: @document.id),
                   users_document_path(@document)
    add_breadcrumb I18n.t('views.user.name.plural'), users_document_users_path(@document)
  end
end
