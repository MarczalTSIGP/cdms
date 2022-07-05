class Users::DocumentSignersController < Users::BaseController
  def sign
    set_document_signer

    if valid_password
      @document_signer.update(signed: true)
      flash[:success] = I18n.t('flash.actions.sign.m', resource_name: I18n.t('views.document.name.singular'))
      redirect_to users_root_path
    else
      flash.now[:error] = I18n.t('flash.actions.sign.errors.incorrect_password')
    end
  end

  private

  def set_document_signer
    @document_signer = current_user
                       .document_signers
                       .find_by(document_id: params[:id])
  end

  def valid_password
    current_user.valid_password?(params[:user][:password])
  end
end
