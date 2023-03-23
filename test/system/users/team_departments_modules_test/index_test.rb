require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'team' do
    setup do
      @user = create(:user)
      login_as(@user, as: :user)
    end

    should 'list departments' do
      departments = create_list(:department, 3)

      departments.each do |department|
        create(:department_user, :collaborator, user: @user, department: department)
      end

      visit users_team_departments_modules_path

      within('table.table tbody') do
        departments.each_with_index do |department, index|
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector "#{base_selector} a[href='#{users_show_department_path(department)}']",
                          text: department.name
          assert_selector base_selector, text: I18n.t('enums.roles.collaborator')
        end
      end
    end

    should 'list modules' do
      department = create(:department)
      create(:department_user, :responsible, user: @user, department: department)

      dep_module = create(:department_module, department: department)
      create(:department_module_user, :collaborator, user: @user, department_module: dep_module)

      visit users_team_departments_modules_path

      within('table.table tbody') do
        base_selector = 'tr:nth-child(1)'

        assert_selector "#{base_selector} a[href='#{users_show_department_path(department)}']",
                        text: department.name
        assert_selector base_selector, text: I18n.t('enums.roles.responsible')

        find("#{base_selector} i[class='fas fa-chevron-right']").click

        base_selector = 'tr:nth-child(2)'

        assert_selector "#{base_selector} a[href='#{users_show_module_path(dep_module)}']",
                        text: dep_module.name
        assert_selector base_selector, text: I18n.t('enums.roles.collaborator')
      end
    end
  end
end
