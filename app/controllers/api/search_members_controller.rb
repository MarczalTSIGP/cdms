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

  def search_non_document_users
    @document = Document.find(params[:document_id])

    non_document_users = @document.search_non_document_users(params[:term])
    render json: non_document_users.as_json(only: [:id, :name, :cpf])
  end

  private

  def find_department
    @department = Department.find(params[:department_id])
  end
end
