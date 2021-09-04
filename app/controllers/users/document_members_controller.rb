class Users::DocumentMembersController < Users::BaseController
  # def index
  #   @document = current_user.documents.find(params[:documentId])
  #   @user = if params[:memberId].to_i >= 1
  #             User.find(params[:memberId])
  #           else 
  #             if params[:memberId]=='nil'
  #               @params.inspect
  #             end
  #           end
  # end

  def members
    @document = current_user.documents.find(params[:document_id])
  end

  def add
    @document = current_user.documents.find(params[:document_id])
    @user = User.find(params[:member][:user_id].to_i);
    @member = {
      "user_id": @user.id,
      "name": @user.name,
      "email": @user.email,
      "register_number": @user.register_number
    }
    @document.update(members: @document.members.push(@member))
    @document = current_user.documents.find(params[:document_id])
    redirect_to controller: 'document_members', action: 'members', document_id: @document.id
    # abort @document.inspect
  end

  def delete
    @document = current_user.documents.find(params[:document_id])
    @user = User.find(params[:user_id].to_i);

    @document.members.each_with_index do |member, index|
      if member['name'] == @user.name
        @document.members.delete(member)
      end
    end

    @document.update(members: @document.members)
    @document = current_user.documents.find(params[:document_id])
    
    redirect_to controller: 'document_members', action: 'members', document_id: params[:document_id]
  end

end
