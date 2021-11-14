class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protected

  def after_sign_in_path_for(*)
    current_user.is?(:admin) ? admins_root_path : users_root_path
  end

  def after_sign_out_path_for(*)
    new_user_session_path
  end

  def layout_by_resource
    return 'layouts/devise/session' if devise_controller?

    'layouts/home/application'
  end
end
