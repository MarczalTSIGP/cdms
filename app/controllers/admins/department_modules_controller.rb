class Admins::DepartmentModulesController < Admins::BaseController
  before_action :set_department
  before_action :set_module, except: [:new, :create, :remove_module_member]
  include DepartmentsMembers
  include Admins::Breadcrumbs::DepartmentModules


  def new
    @module = @department.modules.new
  end

  def edit; end

  def create
    @module = @department.modules.new(module_params)

    if @module.save
      success_create_message
      redirect_to [:admins, @department]
    else
      error_message
      render :new
    end
  end

  def update
    if @module.update(module_params)
      success_update_message
      redirect_to [:admins, @department]
    else
      error_message
      render :edit
    end
  end

  def destroy
    @module.destroy
    success_destroy_message
    redirect_to [:admins, @department]
  end

  # def members
  #   console
  #   @user = DepartmentModuleUser.new
  #   set_department_module_members
  # end

  def add_module_member
    if @module.add_member(users_params)
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_to admins_department_module_members_path(@department, @module)
    else
      set_module_members
      @department_module_user = @module.department_module_users.last
      render :members
    end
  end

  def remove_module_member
    @module = @department.modules.find(params[:module_id])
    @module_user = @module.remove_member(params[:id])

    flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)

    redirect_to admins_department_module_members_path(@department, @module)
  end

  private

  def set_department
    @department = Department.find(params[:department_id])
  end

  def set_department_module_members
    @department_module_users = @module.members
  end

  def set_module
    @module = @department.modules.find(params[:id])
  end

  def module_params
    params.require(:department_module).permit(:name, :description)
  end

  def users_params
    department_module_user = params[:department_module_user]
    { user_id: department_module_user[:user_id],
      role: department_module_user[:role] }
  end
end
