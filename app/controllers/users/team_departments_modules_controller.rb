class Users::TeamDepartmentsModulesController < Users::BaseController
  before_action :breadcrumbs_team

  def index
    @departments = current_user.departments_and_modules
  end

  def show_department
    validation_department_current_user
    add_breadcrumb I18n.t('views.department.links.show'), users_show_department_path(@department)
    @department_users = @department.department_users.includes(:user)
  end

  def show_module
    validation_module_current_user
    add_breadcrumb I18n.t('views.department_module.links.show'), users_show_module_path(@department_module)
    @module_users = @department_module.department_module_users.includes(:user)
  end

  private

  def validation_department_current_user
    id = params[:department_id] || params[:id]
    @department = Department.find(id)

    return unless @department.department_users.where(user_id: current_user.id.to_s).empty?

    redirect_to users_team_departments_modules_path
  end

  def validation_module_current_user
    id = params[:id]
    @department_module = DepartmentModule.find(id)

    return unless @department_module.department_module_users.where(user_id: current_user.id.to_s).empty?

    redirect_to users_team_departments_modules_path
  end

  def breadcrumbs_team
    add_breadcrumb I18n.t('views.team.name.plural'), :users_team_departments_modules_path
  end
end
