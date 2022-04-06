class Api::SearchMembersController < ActionController::API
  def search_non_members
    model_name = params[:model_name]
    @model = model_name.classify.constantize.find(params[:id])
    non_members = @model.search_non_members(params[:term])

    render json: non_members.as_json(only: [:id, :name])
  end
end
