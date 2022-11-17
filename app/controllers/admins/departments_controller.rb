class Admins::DepartmentsController < Admins::BaseController
  before_action :set_department, except: [:index, :new, :create]

  include Breadcrumbs
  include DepartmentsMembers
  include Admins::Breadcrumbs::Departments


  def index
    @departments = Department.search(params[:term])
                             .includes(:responsible)
                             .page(params[:page])
  end

  def show
    @module = DepartmentModule.new(department_id: @department.id)
    @department_modules = @department.modules.includes(:responsible)
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

  private

  def set_department
    id = params[:department_id] || params[:id]
    @department = Department.find(id)
  end

  def set_department_members
    @department_users = @department.members
  end

  def department_params
    params.require(:department).permit(:name, :description, :initials, :local, :phone, :email)
  end

  def users_params
    { user_id: params[:department_user][:user_id],
      role: params[:department_user][:role] }
  end
end
