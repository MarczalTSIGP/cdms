class Api::SearchMembersController < ActionController::API
  def search_non_members
    @model = model.find(params[:id])
    non_members = @model.search_non_members(params[:term])

    render json: non_members.as_json(only: [:id, :name])
  end

  private

  def model
    model_name = params[:model_name].classify

    whitelist = [::Department, ::DepartmentModule]
    whitelist.find { |model| model.name.eql?(model_name) }
  end
end
