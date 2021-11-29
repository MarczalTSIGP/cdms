class Api::SearchMembersController < ActionController::API
  def search_non_members
    find_department
    if params[:module_id].nil?
      non_members = @department.search_non_members(params[:term])
    else
      department_module = @department.modules.find(params[:module_id])
      non_members = department_module.search_non_members(params[:term])
    end
    render json: non_members.as_json(only: [:id, :name])
  end

  def search_non_members_document
    if params[:user_id].nil?
      non_members = @document.search_non_members(params[:term])
    else
      document_user = @document.users.find(params[:user_id])
      non_members = document_user.search_non_members_document(params[:term])
    end
    render json: non_members.as_json(only: [:id, :name])
  end

  private

  def find_department
    @department = Department.find(params[:department_id])
  end
end
