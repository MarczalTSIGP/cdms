require 'application_system_test_case'

class AvailableToSignTest < ApplicationSystemTestCase
  context 'change available to sign attribute' do
    setup do
      user = create(:user, :manager)
      department = create(:department)
      department.department_users.create(user: user, role: :responsible)
      @documents = create_list(:document, 3, :certification, department: department)

      login_as(user, as: :user)
      visit users_documents_path
    end

    should 'not be available to sign' do
      @documents.size.times do |i|
        within("table.table tbody tr:nth-child(#{i + 1}) td:nth-child(4)") do
          assert_text(I18n.t('activerecord.attributes.document.available_to_sign_boolean.false'))
        end
      end
    end

    should 'change to available to sign' do
      document = @documents.last
      find("input[type='checkbox']#document_#{document.id}_available_to_sign").click

      within("table.table tbody tr:nth-child(#{@documents.size}) td:nth-child(4)") do
        assert_text(I18n.t('activerecord.attributes.document.available_to_sign_boolean.true'))
      end
    end
  end
end
