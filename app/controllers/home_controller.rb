class HomeController < ApplicationController
  def index; end

  def about
    @page = Page.find_by(url: 'about')
  end

  def login; end
end
