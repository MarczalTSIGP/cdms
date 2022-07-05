class Admins::DepartmentsController < Admins::BaseController
  before_action :set_department, except: [:index, :new, :create]

  include Breadcrumbs
  include Admins::Breadcrumbs::Departments

  def index
    @departments = Department.search(params[:term]).page(params[:page])
    @responsibles = []
    departments_users(@departments)
    department_responsibles
  end

  def show
    @module = DepartmentModule.new(department_id: @department.id)
    @responsibles = []
    department_modules = @department.modules
    department_module_users(department_modules)
    module_responsibles(department_modules)
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
    @department_user = DepartmentUser.new
    set_department_members
  end

  def add_member
    if @department.add_member(users_params)
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_to admins_department_members_path(@department)
    else
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
    @department_users = @department.members
  end

  def department_params
    params.require(:department).permit(:name, :description, :initials, :local, :phone, :email)
  end

  def users_params
    { user_id: params[:department_user][:user_id],
      role: params[:department_user][:role] }
  end

  def departments_users(departments)
    @departments_users = DepartmentUser.where(role: :responsible, department_id: departments).includes(:user)
  end

  def department_module_users(department_modules)
    @department_module_users = DepartmentModuleUser.where(role: :responsible,
                                                          department_module_id: department_modules).includes(:user)
  end

  def department_responsibles
    @departments.each do |dep|
      added = false

      @departments_users.each do |dep_user|
        if dep.id == dep_user.department_id
          @responsibles.push(dep_user)
          added = true
        end
      end

      @responsibles.push(dep) if added.eql? false
    end
  end

  def module_responsibles(department_modules)
    department_modules.each do |modulo|
      added = false

      @department_module_users.each do |module_user|
        if modulo.id.eql? module_user.department_module_id
          @responsibles.push(module_user)
          added = true
        end
      end

      @responsibles.push(modulo) if added.eql? false
    end
  end
end
