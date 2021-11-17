class Admins::PagesController < Admins::BaseController
  add_breadcrumb Page.model_name.human(count: 2), :admins_edit_about_page_path

  before_action :set_page, only: [:edit, :update]

  def edit; end

  def update
    if @page.update(page_params)
      success_update_message
      redirect_to admins_edit_about_page_path
    else
      error_message
      render :edit
    end
  end

  private

  def page_params
    params.require(:page).permit(:content)
  end

  def set_page
    @page = Page.first
  end
end
