require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'document roles' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
    end

    should 'list all' do
      document_roles = create_list(:document_role, 3)
      visit admins_document_roles_path

      within('table.table tbody') do
        document_roles.each_with_index do |document_role, index|
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector base_selector, text: document_role.name
          assert_selector base_selector, text: document_role.description

          assert_selector "#{base_selector} a[href='#{edit_admins_document_role_path(document_role)}']"
          assert_selector "#{base_selector} a[href='#{admins_document_role_path(document_role)}'][data-method='delete']"
        end
      end
    end

    should 'search' do
      first_name = 'Estudante'
      second_name = 'Professor'

      FactoryBot.create(:document_role, name: first_name)
      FactoryBot.create(:document_role, name: second_name)

      visit admins_document_roles_path

      fill_in 'search', with: second_name
      submit_form('button.submit-search')

      assert_selector 'tr:nth-child(1) td:nth-child(1)', text: second_name
    end
  end
end
