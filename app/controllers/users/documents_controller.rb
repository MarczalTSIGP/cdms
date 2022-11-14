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
    render layout: 'users/document_preview'
  end

  def new
    @document = Document.new
  end

  def edit
    if @document.someone_signed?
      flash[:warning] = t('flash.actions.edit.non')
      redirect_to users_documents_path
    else
      render :edit
    end
  end

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

  private

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
    params.require(:document).permit(:title, :front_text, :back_text, :category,
                                     :department_id, :variables, :available_to_sign)
  end
end
