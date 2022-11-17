module DepartmentsMembers
  extend ActiveSupport::Concern

  def members
    @user = (controller_name.camelize.singularize + "User").constantize.new
    send("set_#{controller_name.singularize}_members")
  end

  def add_member
    if variable_model.add_member(users_params)
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_to send("admins_#{controller_name.singularize}_members_path", @department, @module)
    else
      @user = variable_model.send("#{controller_name.singularize}_users").last
      send("set_#{controller_name.singularize}_members")
      render :members
    end
  end

  def remove_member
    remove
    flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)
    redirect_to send("admins_#{controller_name.singularize}_members_path", @department, @module)
  end

  private 

  def variable_model
    return controller_name == "departments" ? @department : @module
  end 

  def remove 
    if controller_name == "departments"
      @department.remove_member(params[:id])
    else
      @module = @department.modules.find(params[:module_id])
      @module_user = @module.remove_member(params[:id])
    end
  end
end
