class Users::DepartmentsController < Users::BaseController
  before_action :set_department
  before_action :can_manager?

  def members
    breadcrumbs_members
    @department_user = DepartmentUser.new
    @department_users = @department.members
  end

  def add_member
    if users_params[:user_id].present?
      @department.add_member(users_params)
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
    else
      flash[:warning] = I18n.t('flash.actions.add.errors.not')
    end
    redirect_to users_department_members_path(@department)
  end

  def remove_member
    if try_to_remove_current_user?
      flash[:warning] = I18n.t('flash.actions.reponsible.removeitself')
    else
      @department.remove_member(params[:id])
      flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)
    end

    redirect_to users_department_members_path(@department)
  end

  private

  def try_to_remove_current_user?
    current_user.id == params[:id].to_i
  end

  def can_manager?
    return if current_user.responsible_of?(@department)

    flash[:warning] = t('flash.actions.responsible.non')
    redirect_to users_show_department_path(@department)
  end

  def set_department
    id = params[:department_id] || params[:id]
    @department = Department.find(id)
  end

  def department_params
    params.require(:department).permit(:name, :description, :initials, :local, :phone, :email)
  end

  def users_params
    { user_id: params[:department_user][:user_id],
      role: :collaborator }
  end

  def breadcrumbs_members
    add_breadcrumb I18n.t('views.breadcrumbs.show', model: Department.model_name.human, id: @department.id),
                   users_show_department_path(@department)
    add_breadcrumb I18n.t('views.department.members.name'), users_department_members_path(@department)
  end
end
