module DepartmentsMembers
  extend ActiveSupport::Concern

  def members
    @user = (controller_name.camelize.singularize + "User").constantize.new
    send("set_#{controller_name.singularize}_members")
  end

  # def add_module_member
  #   if @module.add_member(users_params)
  #     flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
  #     redirect_to send("admins_#{controller_name}_members_path(@department, @module)")
  #   else
  #     @department_module_user = @module.department_module_users.last
  #     send("set_#{controller_name}_members")
  #     render :members
  #   end
  # end

  # def remove_module_member
  #   @module = @department.modules.find(params[:module_id])
  #   @module_user = @module.remove_member(params[:id])

  #   flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)

  #   redirect_to send("admins_#{controller_name}_members_path(@department, @module)")
  # end
end
