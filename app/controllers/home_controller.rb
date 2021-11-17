class HomeController < ApplicationController
  def index; end

  def about
    @page = Page.first
  end

  def login; end
end
