class Users::DashboardController < Users::BaseController
  def index
    @unsigned_documents = current_user.unsigned_documents
  end
end
