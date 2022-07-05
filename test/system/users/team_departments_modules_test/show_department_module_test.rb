require 'application_system_test_case'

class ShowDepartmentModuleTest < ApplicationSystemTestCase
  context 'module' do
    setup do
      @user = create(:user)
      login_as(@user, as: :user)

      @dep_module = create(:department_module)
      create(:department_module_user, :responsible, user: @user, department_module: @dep_module)
    end

    should 'display module data' do
      visit users_show_module_path(@dep_module)

      within('#main-content .card.department-module-data .card-body') do
        assert_text @dep_module.name
        assert_text @dep_module.description
        assert_text @dep_module.responsible&.name
      end
    end

    should 'display text and options' do
      visit users_show_module_path(@dep_module)
      within('#main-content .card-body .footer') do
        assert_link(I18n.t('views.links.back'), href: users_team_departments_modules_path)
      end
    end

    should 'list members' do
      users = create_list(:user, 3)
      users.each do |user|
        create(:department_module_user, :collaborator, user: user, department_module: @dep_module)
      end

      visit users_show_module_path(@dep_module)

      within('.card.team table.table tbody') do
        base_selector = 'tr:nth-child(1)'
        assert_selector base_selector, text: @user.name
        assert_selector base_selector, text: @user.email
        assert_selector base_selector, text: I18n.t('enums.roles.responsible')

        users.each_with_index do |user, index|
          child = index + 2
          base_selector = "tr:nth-child(#{child})"

          assert_selector base_selector, text: user.name
          assert_selector base_selector, text: user.email
          assert_selector base_selector, text: I18n.t('enums.roles.collaborator')
        end
      end
    end
  end
end
