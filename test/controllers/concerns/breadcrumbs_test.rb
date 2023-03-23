require 'test_helper'

class BreadcrumbsTest < ActionController::TestCase
  context 'CRUD' do
    setup do
      Rails.application.routes.draw do
        resources :breadcrumbs
      end
      @controller = BreadcrumbsController.new
    end

    teardown do
      Rails.application.reload_routes!
    end

    should 'have to index' do
      get :index

      crumb = breadcrumbs.first

      assert_equal breadcrumbs_path, crumb.path
      assert_equal Breadcrumb.model_name.human(count: 2), crumb.name
    end

    should 'have to new' do
      get :new

      crumb_one, crumb_two = breadcrumbs

      assert_equal breadcrumbs_path, crumb_one.path
      assert_equal Breadcrumb.model_name.human(count: 2), crumb_one.name

      assert_equal new_breadcrumb_path, crumb_two.path
      assert_equal I18n.t('views.breadcrumbs.new.m'), crumb_two.name
    end

    should 'have to create' do
      post :create

      crumb_one, crumb_two = breadcrumbs

      assert_equal breadcrumbs_path, crumb_one.path
      assert_equal Breadcrumb.model_name.human(count: 2), crumb_one.name

      assert_equal new_breadcrumb_path, crumb_two.path
      assert_equal I18n.t('views.breadcrumbs.new.m'), crumb_two.name
    end

    should 'have to show' do
      get :show, params: { id: 1 }

      crumb_one, crumb_two = breadcrumbs

      assert_equal breadcrumbs_path, crumb_one.path
      assert_equal Breadcrumb.model_name.human(count: 2), crumb_one.name

      breadcrumb = Breadcrumb.new

      assert_equal breadcrumb_path(breadcrumb), crumb_two.path
      assert_equal I18n.t('views.breadcrumbs.show', model: breadcrumb.model_name.human,
                                                    id: breadcrumb.id), crumb_two.name
    end

    should 'have to edit' do
      get :edit, params: { id: 1 }

      crumb_one, crumb_two, crumb_three = breadcrumbs

      assert_equal breadcrumbs_path, crumb_one.path
      assert_equal Breadcrumb.model_name.human(count: 2), crumb_one.name

      breadcrumb = Breadcrumb.new

      assert_equal breadcrumb_path(breadcrumb), crumb_two.path
      assert_equal I18n.t('views.breadcrumbs.show', model: breadcrumb.model_name.human,
                                                    id: breadcrumb.id), crumb_two.name

      assert_equal edit_breadcrumb_path(breadcrumb), crumb_three.path
      assert_equal I18n.t('views.breadcrumbs.edit'), crumb_three.name
    end

    should 'have to update' do
      get :update, params: { id: 1 }

      crumb_one, crumb_two, crumb_three = breadcrumbs

      assert_equal breadcrumbs_path, crumb_one.path
      assert_equal Breadcrumb.model_name.human(count: 2), crumb_one.name

      breadcrumb = Breadcrumb.new

      assert_equal breadcrumb_path(breadcrumb), crumb_two.path
      assert_equal I18n.t('views.breadcrumbs.show', model: breadcrumb.model_name.human,
                                                    id: breadcrumb.id), crumb_two.name

      assert_equal edit_breadcrumb_path(breadcrumb), crumb_three.path
      assert_equal I18n.t('views.breadcrumbs.edit'), crumb_three.name
    end
  end

  context 'with namespace and args' do
    setup do
      class Admins::BreadcrumbsController < ActionController::Base
        include Breadcrumbs
        breadcrumbs_options :female

        def new
          head :ok
        end
      end

      Rails.application.routes.draw do
        namespace :admins do
          resources :breadcrumbs, only: [:new, :index]
        end
      end

      @controller = Admins::BreadcrumbsController.new
    end

    teardown do
      Rails.application.reload_routes!
    end

    should 'have to new with female arg' do
      get :new

      crumb_one, crumb_two = breadcrumbs

      assert_equal admins_breadcrumbs_path, crumb_one.path
      assert_equal Breadcrumb.model_name.human(count: 2), crumb_one.name

      assert_equal new_admins_breadcrumb_path, crumb_two.path
      assert_equal I18n.t('views.breadcrumbs.new.f'), crumb_two.name
    end
  end

  private

  def breadcrumbs
    @controller.send :breadcrumbs_on_rails
  end
end

class BreadcrumbsController < ActionController::Base
  before_action :set_breadcrumb, only: [:show, :edit, :update]
  include Breadcrumbs

  def index
    head :ok
  end

  def new
    head :ok
  end

  def create
    head :ok
  end

  def show
    head :ok
  end

  def edit
    head :ok
  end

  def update
    head :ok
  end

  def set_breadcrumb
    @breadcrumb = Breadcrumb.new
  end
end

class Breadcrumb
  extend ActiveModel::Naming
  def id
    1
  end

  def to_param
    id.to_s
  end
end
