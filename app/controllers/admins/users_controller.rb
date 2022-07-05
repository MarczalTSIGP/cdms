class Admins::UsersController < Admins::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  include Breadcrumbs

  def index
    @users = User.search(params[:term]).page(params[:page]).order('name ASC')
  end

  def show; end

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)

    if @user.save
      success_create_message
      redirect_to admins_users_path

    else
      error_message
      render :new
    end
  end

  def update
    remove_empty_password

    if @user.update(user_params)
      success_update_message
      redirect_to admins_users_path
    else
      error_message
      render :edit
    end
  end

  def destroy
    if @user.destroy
      success_destroy_message
    else
      flash[:warning] = @user.errors.messages[:base].join
    end

    redirect_to admins_users_path
  end

  private

  def remove_empty_password
    user_param = params[:user]
    return if user_param[:password].present?

    user_param.delete(:password)
    user_param.delete(:password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :username, :register_number,
                                 :cpf, :active, :avatar, :password, :password_confirmation)
  end
end
