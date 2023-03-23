class Admins::AudienceMembersController < Admins::BaseController
  before_action :set_audience_member, only: [:edit, :update, :show, :destroy]
  include Breadcrumbs

  def index
    @audience_members = AudienceMember.search(params[:term]).page(params[:page])
  end

  def show; end

  def new
    @audience_member = AudienceMember.new
  end

  def edit; end

  def create
    @audience_member = AudienceMember.new(audience_member_params)
    save_audience_member
  end

  def update
    @audience_member.assign_attributes(audience_member_params)
    save_audience_member
  end

  def destroy
    @audience_member.destroy
    success_destroy_message
    redirect_to admins_audience_members_path
  end

  def from_csv
    add_breadcrumb t('views.audience_member.import.btn_csv'), admins_new_audience_members_from_csv_path
  end

  def create_from_csv
    add_breadcrumb t('views.audience_member.import.btn_csv'), admins_create_audience_members_from_csv_path

    if params[:csv]
      process_csv
    else
      flash.now[:error] = t('flash.actions.import.errors.blank')
    end

    render :from_csv
  end

  private

  def process_csv
    @result = AudienceMember.from_csv(params[:csv][:file].tempfile)

    if @result.valid_file?
      flash.now[:success] = t('flash.actions.import.m', resource_name: t('activerecord.models.audience_member.other'))
    else
      flash.now[:error] = t('flash.actions.import.errors.invalid')
    end
  end

  def set_audience_member
    @audience_member = AudienceMember.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('flash.not_found')
    redirect_to admins_audience_members_path
  end

  def audience_member_params
    params.require(:audience_member).permit(:id, :name, :email, :cpf, :password, :password_confirmation)
  end

  def save_audience_member
    if @audience_member.save
      send("success_#{action_name}_message")
      redirect_to admins_audience_members_path
    else
      error_message
      render @audience_member.new_record? ? :new : :edit
    end
  end
end
