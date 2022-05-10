class Admins::DepartmentsController < Admins::BaseController
  before_action :set_department, except: [:index, :new, :create]
  include Breadcrumbs
  include BreadcrumbsMembers

  def index
    @departments = Department.search(params[:term]).page(params[:page])
  end

  def show
    @module = DepartmentModule.new(department_id: @department.id)
  end

  def new
    @department = Department.new
  end

  def edit; end

  def create
    @department = Department.new(department_params)

    if @department.save
      success_create_message
      redirect_to admins_departments_path
    else
      error_message
      render :new
    end
  end

  def update
    if @department.update(department_params)
      success_update_message
      redirect_to admins_departments_path
    else
      error_message
      render :edit
    end
  end

  def destroy
    @department.destroy
    success_destroy_message
    redirect_to admins_departments_path
  end

  def members
    breadcrumbs_members(@department)
    @department_user = DepartmentUser.new
    set_department_members
  end

  def add_member
    if @department.add_member(users_params)
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_to admins_department_members_path(@department)
    else
      breadcrumbs_members(@department)
      @department_user = @department.department_users.last
      set_department_members
      render :members
    end
  end

  def remove_member
    @department.remove_member(params[:id])
    flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)
    redirect_to admins_department_members_path(@department)
  end

  private

  def set_department
    id = params[:department_id] || params[:id]
    @department = Department.find(id)
  end

  def set_department_members
    @department_users = @department.members(:user)
  end

  def department_params
    params.require(:department).permit(:name, :description, :initials, :local, :phone, :email)
  end

  def users_params
    { user_id: params[:department_user][:user_id],
      role: params[:department_user][:role] }
  end
end
