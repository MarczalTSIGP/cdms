class Users::DocumentMemberController < Users::BaseController
  def index
    @document = current_user.documents.find(params[:documentId])
    @user = if params[:memberId].to_i >= 1
              User.find(params[:memberId])
            else 
              if params[:memberId]=='nil'
                @params.inspect
              end
            end
  end

  def list
    @document_member = DocumentMember.find(params[:documentId]) rescue []
  end

  def show
    
  end

  def add

  end
end
