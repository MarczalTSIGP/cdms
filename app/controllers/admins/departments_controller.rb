class Admins::DepartmentsController < Admins::BaseController
  before_action :set_department, except: [:index, :new, :create]

  include Breadcrumbs
  include Admins::Breadcrumbs::Departments
  include DepartmentMembers

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

  def department_params
    params.require(:department).permit(:name, :description, :initials, :local, :phone, :email)
  end
end
