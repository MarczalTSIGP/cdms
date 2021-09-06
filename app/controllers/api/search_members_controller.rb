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

  def search_users
    members = User.search(params[:term]).page(params[:page]).order('name ASC')
    render json: members.as_json(only: [:id, :name])
  end

  private

  def find_department
    @department = Department.find(params[:department_id])
  end
end
