require 'application_system_test_case'

class ShowDepartmentTest < ApplicationSystemTestCase
  context 'department' do
    setup do
      @user = create(:user)
      login_as(@user, as: :user)
      @department = create(:department)
      create(:department_user, :responsible, user: @user, department: @department)
    end

    should 'display department data' do
      visit users_show_department_path(@department)

      within('#main-content .card.department-data .card-body') do
        assert_text @department.name
        assert_text @department.initials
        assert_text @department.phone
        assert_text @department.email
        assert_text @department.local
        assert_text @department.description
        assert_text @department.responsible&.name
      end
    end

    should 'display text and options' do
      visit users_show_department_path(@department)

      within('#main-content .card-body .footer') do
        assert_link(I18n.t('views.links.back'), href: users_team_departments_modules_path)
      end
    end

    should 'list members' do
      users = create_list(:user, 3)
      users.each do |user|
        create(:department_user, :collaborator, user: user, department: @department)
      end

      visit users_show_department_path(@department)

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
