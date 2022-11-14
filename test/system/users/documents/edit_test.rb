require 'application_system_test_case'

class EditTest < ApplicationSystemTestCase
  context 'document' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)
    end

    context 'edit document someone signed' do
      setup do
        user = create(:user, :manager)
        @department = create(:department)
        @department.department_users.create(user: user, role: :responsible)
        @document = create(:document, :certification, department: @department)
  
        login_as(user, as: :user)
  
        visit edit_users_document_path(@document)
      end

      should 'successfully' do

      assert_selector('div.alert.alert-warning', text: I18n.t('flash.actions.edit.non'))

      end
    end
  end
end
