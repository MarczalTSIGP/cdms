class Admins::DepartmentModulesController < Admins::BaseController
  before_action :set_department
  before_action :set_module, except: [:new, :create]

  include DepartmentMembers
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

  private

  def set_department
    @department = Department.find(params[:department_id])
  end

  def set_module
    # necessary for Members Controller Concern
    id = params[:module_id] || params[:id]
    @department_module = @department.modules.find(id)

    @module = @department_module # just an abreviation
  end

  def module_params
    params.require(:department_module).permit(:name, :description)
  end
end
