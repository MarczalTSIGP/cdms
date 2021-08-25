class Users::DocumentMemberController < Users::BaseController

    def index
        @document = current_user.documents.find(params[:documentId])
        if params[:memberId].to_i >= 1
            @user = User.find(params[:memberId])
        else
            @user = User.new
        end
    end

end