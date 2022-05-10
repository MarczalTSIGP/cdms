class Users::DocumentsController < Users::BaseController
  before_action :can_manager?, only: [:edit, :new, :update, :create, :destroy]
  before_action :set_document, except: [:index, :new, :create]
  before_action :set_departments, only: [:edit, :new, :update, :create]
  include Breadcrumbs
  include BreadcrumbsMembers

  def members
    breadcrumbs_members(@document)
    @document_user = DocumentUser.new
    @document_users = @document.members(:user, :document_role)
  end

  def add_member
    breadcrumbs_members(@document)

    if @document.add_member(users_params)
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_to users_document_members_path(@document)
    else
      @document_user = @document.document_users.last
      set_document_members
      render :members
    end
  end

  def remove_member
    @document.remove_member(params[:id])
    flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)
    redirect_to users_document_members_path(@document)
  end

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

  private

  def can_manager?
    return true if current_user.member_of_any?

    flash[:warning] = t('flash.actions.member.non')
    redirect_to users_documents_path
  end

  def set_document
    id = params[:document_id] || params[:id]
    @document = Document.find(id)
  end

  def set_departments
    @departments = current_user.departments
  end

  def set_document_members
    @document_users = @document.members(:user, :document_role)
  end

  def create_document
    department_id = document_params[:department_id]
    if department_id.present?
      department = current_user.departments.find(department_id)
      department.documents.create(document_params)
    else
      Document.new(document_params)
    end
  end

  def document_params
    params.require(:document).permit(:title, :front_text, :back_text, :category,
                                     :department_id, :variables, :available_to_sign)
  end

  def users_params
    { user_id: params[:document_user][:user_id], document_role_id: params[:document_user][:document_role] }
  end

  def search_non_members_document
    user_id = params[:user_id]
    term = params[:term]
    if user_id
      non_members = @document.search_non_members(term)
    else
      document_user = @document.users.find(user_id)
      non_members = document_user.search_non_members_document(term)
    end
    render json: non_members.as_json(only: [:id, :name])
  end
end
