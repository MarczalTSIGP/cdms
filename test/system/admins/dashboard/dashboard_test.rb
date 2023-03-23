require 'application_system_test_case'

class DashboardTest < ApplicationSystemTestCase
  context 'dashboard' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
    end

    should 'display breadcrumbs' do
      visit admins_root_path

      assert_selector 'ol.breadcrumb li:first-child', text: I18n.t('views.breadcrumbs.home')
    end

    should 'display sidebar' do
      visit admins_root_path

      assert_selector '.list-group-item', text: I18n.t('views.app.sidebar.home_page')
      assert_selector '.list-group-item', text: I18n.t('views.app.sidebar.departments')
      assert_selector '.list-group-item', text: I18n.t('views.app.sidebar.audience_members')
      assert_selector '.list-group-item', text: I18n.t('views.app.sidebar.users')
      assert_selector '.list-group-item', text: I18n.t('views.app.sidebar.administrators')
    end

    should 'display the number of departments in singular mode' do
      create(:department)
      visit admins_root_path

      selector = 'div.row.row-cards div.card:first-child .card-body'

      assert_selector selector, text: 1
      assert_selector selector, text: Department.model_name.human(count: 1)
    end

    should 'display the number of departments in plural mode' do
      create_list(:department, 3)
      visit admins_root_path

      selector = 'div.row.row-cards div.card:first-child .card-body'

      assert_selector selector, text: 3
      assert_selector selector, text: Department.model_name.human(count: 3)
    end

    should 'display the number of active users in singular mode' do
      visit admins_root_path

      selector = 'div.row.row-cards div.col-sm-3:nth-child(2)'

      assert_selector selector, text: 1
      assert_selector selector, text: User.model_name.human(count: 1)
    end

    should 'display the number of active users in plural mode' do
      create_list(:user, 2, active: true)
      visit admins_root_path

      selector = 'div.row.row-cards div.col-sm-3:nth-child(2)'

      assert_selector selector, text: 3
      assert_selector selector, text: User.model_name.human(count: 3)
    end

    should 'display the number of inactive users in singular mode' do
      create(:user, active: false)
      visit admins_root_path

      selector = 'div.row.row-cards div.col-sm-3:nth-child(3)'

      assert_selector selector, text: 1
      assert_selector selector, text: User.model_name.human(count: 1)
    end

    should 'display the number of inactive users in plural mode' do
      create_list(:user, 3, active: false)
      visit admins_root_path

      selector = 'div.row.row-cards div.col-sm-3:nth-child(3)'

      assert_selector selector, text: 3
      assert_selector selector, text: User.model_name.human(count: 3)
    end

    should 'display the number of audience members in singular mode' do
      create(:audience_member)
      visit admins_root_path

      selector = 'div.row.row-cards div.col-sm-3:nth-child(4)'

      assert_selector selector, text: 1
      assert_selector selector, text: AudienceMember.model_name.human(count: 1)
    end

    should 'display the number of audience members in plural mode' do
      create_list(:audience_member, 3)
      visit admins_root_path

      selector = 'div.row.row-cards div.col-sm-3:nth-child(4)'

      assert_selector selector, text: 3
      assert_selector selector, text: AudienceMember.model_name.human(count: 3)
    end
  end
end
