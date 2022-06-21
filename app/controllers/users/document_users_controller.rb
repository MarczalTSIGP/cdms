class Users::DocumentUsersController < Users::BaseController
  def sign_document
    set_document_user

    if valid_password
      @document_user.toggle(:signed).save!
      flash[:success] = I18n.t('flash.actions.sign.m', resource_name: I18n.t('views.document.name.singular'))
    else
      flash[:error] = I18n.t('flash.actions.sign.errors.incorrect_password')
    end

    redirect_to users_root_path
  end

  def set_document_user
    @document_user = current_user.document_users.find_by(document_id: params[:id])
  end

  def valid_password
    current_user.valid_password?(params[:document][:password])
  end
end
