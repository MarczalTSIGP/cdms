class Users::DocumentMemberController < Users::BaseController
  def index
    @document = current_user.documents.find(params[:documentId])
    @user = if params[:memberId].to_i >= 1
              User.find(params[:memberId])
            else
              User.new
            end
  end

  def list
    @document_members = DocumentMember.search(:cpf)
  end
end
