require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'departments' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
    end

    should 'list all' do
      departments = create_list(:department, 3)
      visit admins_departments_path

      within('table.table tbody') do
        departments.each_with_index do |department, index|
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector "#{base_selector} a[href='#{admins_department_path(department)}']",
                          text: department.name
          assert_selector base_selector, text: department.phone
          assert_selector base_selector, text: department.email
          assert_selector base_selector, text: ''
          assert_selector base_selector, text: 0

          assert_selector "#{base_selector} a[href='#{edit_admins_department_path(department)}']"
          assert_selector "#{base_selector} a[href='#{admins_department_path(department)}'][data-method='delete']"
        end
      end
    end

    should 'list all with collaborators' do
      departments = create_list(:department, 3)
      users = create_list(:user, 3)

      users.each_with_index do |user, index|
        create(:department_user, department_id: departments[index].id, user_id: user.id, role: :collaborator)
      end

      visit admins_departments_path

      within('table.table tbody') do
        departments.each_with_index do |department, index|
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector "#{base_selector} a[href='#{admins_department_path(department)}']",
                          text: department.name
          assert_selector base_selector, text: department.phone
          assert_selector base_selector, text: department.email
          assert_selector base_selector, text: ''
          assert_selector base_selector, text: 1
        end
      end
    end

    should 'list all with responsibles and collaborators' do
      departments = create_list(:department, 2)
      users = create_list(:user, 2)

      create(:department_user, department_id: departments[0].id, user_id: users[0].id, role: :responsible)
      create(:department_user, department_id: departments[0].id, user_id: users[1].id, role: :collaborator)
      create(:department_user, department_id: departments[1].id, user_id: users[1].id, role: :responsible)
      create(:department_user, department_id: departments[1].id, user_id: users[0].id, role: :collaborator)

      responsibles = DepartmentUser.where(role: :responsible)

      visit admins_departments_path

      within('table.table tbody') do
        departments.each_with_index do |department, index|
          child = index + 1
          base_selector = "tr:nth-child(#{child})"
          assert_selector "#{base_selector} a[href='#{admins_department_path(department)}']",
                          text: department.name
          assert_selector base_selector, text: department.phone
          assert_selector base_selector, text: department.email
          assert_selector base_selector, text: responsibles[index].user.name
          assert_selector base_selector, text: 2
        end
      end
    end

    should 'search' do
      first_name = 'TSI'
      second_name = 'TMI'

      FactoryBot.create(:department, name: first_name)
      FactoryBot.create(:department, name: second_name)

      visit admins_departments_path

      fill_in 'search', with: second_name
      submit_form('button.submit-search')

      assert_selector 'tr:nth-child(1) td:nth-child(1)', text: second_name
    end

    should 'display' do
      visit admins_departments_path

      assert_selector '#main-content .card-header', text: I18n.t('views.department.name.plural')
      assert_selector "#main-content a[href='#{new_admins_department_path}']",
                      text: I18n.t('views.department.links.new')
    end
  end
end
