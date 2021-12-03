require 'application_system_test_case'

class Users::UserTest < ApplicationSystemTestCase
  context 'document_users' do
    setup do
      @user = create(:user, :manager)
      @department = create(:department)
      @department.department_users.create(user: @user, role: :responsible)
      @document = create(:document, :certification, department: @department)

      login_as(@user, as: :user)
      visit users_document_users_path(@document)
    end

    context 'add_document_user' do
      should 'successfully' do
        fill_in 'document_receiver_user', with: @user.name
        find("#document_receiver_user-dropdown .dropdown-item[data-value='#{@user.id}']").click

        submit_form("button[type='submit']")
        @user.reload

        html = 'table tbody tr:nth-child(1)'
        assert_selector html, text: @user.id
        assert_selector html, text: @user.name
        assert_selector html, text: @user.cpf
        assert_selector "#{html} a[href='#{users_document_remove_user_path(@document, @user)}'][data-method='delete']"
      end

      should 'unsuccessfully' do
        submit_form("button[type='submit']")

        within('div.document_receiver_user') do
          assert_text(I18n.t('errors.messages.blank'))
        end
      end
    end

    should 'destroy' do
      fill_in 'document_receiver_user', with: @user.name
      find("#document_receiver_user-dropdown .dropdown-item[data-value='#{@user.id}']").click

      submit_form("button[type='submit']")
      @user.reload

      within('table tbody tr:nth-child(1)') do
        accept_confirm do
          find("a[href='#{users_document_remove_user_path(@document, @user)}'][data-method='delete']").click
        end
      end

      assert_current_path users_document_users_path(@document)

      within('table tbody') do
        refute_text @user.name
        refute_selector "a[href='#{users_document_remove_user_path(@document, @user)}'][data-method='delete']"
      end
    end
  end
end
