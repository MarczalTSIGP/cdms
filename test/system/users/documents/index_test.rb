require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'documents:index' do
    setup do
      user = create(:user, :manager)
      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)

      login_as(user, as: :user)
    end

    context 'list' do
      setup do
        # logged user
        @documents = create_list(:document, 3, :certification, department: @department)

        # same department user
        @department.department_users.create(user: create(:user), role: :collaborator)
        @documents << create(:document, :declaration, department: @department)

        # other department user
        department = create(:department)
        department.department_users.create(user: create(:user), role: :responsible)
        @non_member_documents = create_list(:document, 3, :declaration, department: department)
      end

      should 'all departments of the current user is member' do
        visit users_documents_path

        within('table.table tbody') do
          @documents.each_with_index do |document, index|
            child = index + 1
            base_selector = "tr:nth-child(#{child})"

            assert_selector base_selector, text: document.title

            assert_selector "#{base_selector} a[href='#{edit_users_document_path(document)}']"
            href = users_document_path(document)

            assert_selector "#{base_selector} a[href='#{href}'][data-method='delete']"
          end
        end
      end

      should 'not list from non member deartments' do
        visit users_documents_path

        within('table.table tbody') do
          @non_member_documents.each do |document|
            assert_no_selector "a[href='#{edit_users_document_path(document)}']"
            assert_no_selector "a[href='#{users_document_path(document)}'][data-method='delete']"
          end
        end
      end
    end

    should 'search' do
      first_title = 'Primeiro título'
      second_title = 'Segundo título'

      create(:document, title: first_title, department: @department, category: :certification)
      create(:document, title: second_title, department: @department, category: :certification)

      visit users_documents_path

      fill_in 'search', with: second_title
      submit_form('button.submit-search')

      assert_selector 'tr:nth-child(1)', text: second_title
    end

    should 'display' do
      visit users_documents_path

      assert_selector '#main-content .card-header', text: I18n.t('activerecord.models.document.other')
      assert_selector "#main-content a[href='#{new_users_document_path}']",
                      text: I18n.t('views.document.links.new')
    end
  end
end
