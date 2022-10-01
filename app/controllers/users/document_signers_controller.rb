class Users::DocumentSignersController < Users::BaseController
  before_action :set_document, except: :sign

  include Users::Breadcrumbs::DocumentSigners

  def signers
    @document_signer = DocumentSigner.new
    set_document_signers
  end

  def add_signer
    if @document.add_signing_member(users_params)
      notify_signer
      flash[:success] = I18n.t('flash.actions.add.m', resource_name: User.model_name.human)
      redirect_to users_document_signers_path(@document)
    else
      @document_signer = @document.document_signers.last
      set_document_signers
      render :signers
    end
  end

  def remove_signer
    @document.remove_signing_member(params[:id])
    flash[:success] = I18n.t('flash.actions.remove.m', resource_name: User.model_name.human)
    redirect_to users_document_signers_path(@document)
  end

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

  def set_document
    id = params[:document_id] || params[:id]
    @document = Document.find(id)
  end

  def set_document_signers
    @document_signers = @document.signing_members.includes(:document_role)
  end

  def set_document_signer
    @document_signer = current_user
                       .document_signers
                       .find_by(document_id: params[:id])
  end

  def valid_password
    current_user.valid_password?(params[:user][:password])
  end

  def users_params
    document_signer = params[:document_signer]
    { user_id: document_signer[:user_id], document_role_id: document_signer[:document_role] }
  end

  def notify_signer
    NotifyDocumentToSignMailer.with(user_id: users_params[:user_id], document: @document).notify_sign.deliver_later
  end
end
