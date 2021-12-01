class Admins::DocumentRolesController < Admins::BaseController
  before_action :set_document_role, except: [:index, :new, :create]
  include Breadcrumbs
  def index
    @document_roles = DocumentRole.search(params[:term]).page(params[:page])
  end

  def show
    @document_role = DocumentRole.find(params[:id])
  end

  def new
    @document_role = DocumentRole.new
  end

  def edit; end

  def create
    @document_role = DocumentRole.new(document_role_params)

    if @document_role.save
      success_create_message
      flash[:success] = I18n.t('flash.actions.add.f', resource_name: t('views.document_role.name.singular'))
      redirect_to admins_document_roles_path
    else
      error_message
      flash[:error] = I18n.t('flash.actions.errors', resource_name: t('views.document_role.name.singular'))
      render :new
    end
  end

  def update
    if @document_role.update(document_role_params)
      success_update_message
      flash[:success] = I18n.t('flash.actions.update.f', resource_name: t('views.document_role.name.singular'))
      redirect_to admins_document_roles_path
    else
      error_message
      render :edit
    end
  end

  def destroy
    @document_role.destroy
    feminine_success_destroy_message
    redirect_to admins_document_roles_path
  end

  private

  def set_document_role
    @document_role = DocumentRole.find(params[:id])
  end

  def document_role_params
    params.require(:document_role).permit(:name, :description)
  end
end
