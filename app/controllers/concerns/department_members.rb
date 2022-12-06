module DepartmentMembers
  extend ActiveSupport::Concern

  def members
    model_class = "#{controller_name.camelize.singularize.constantize}User".constantize
    @member = model_class.new

    set_members
  end

  def add_member
    if model_instance.add_member(member_params)
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_back fallback_location: admins_root_path
    else
      set_members

      # get last user added unsuccessfully, this is necessary to display the erros
      method_name = "#{controller_name.singularize}_users"
      @member = model_instance.send(method_name).last

      render :members
    end
  end

  def remove_member
    model_instance.remove_member(params[:id])

    flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)

    redirect_back fallback_location: admins_root_path
  end

  private

  def set_members
    model_instance = instance_variable_get("@#{controller_name.singularize}")
    @members = model_instance.members
  end

  def member_params
    { user_id: params[:member][:user_id], role: params[:member][:role] }
  end

  def model_instance
    instance_variable_get("@#{controller_name.singularize}")
  end
end
