require 'application_system_test_case'

class MembersTest < ApplicationSystemTestCase
  context 'document' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)
    end

    context 'add member' do
      setup do
        @document = create(:document)
        @user = create(:user)
        visit users_document_members_path(@document)
      end

      should 'successfully' do
        fill_in 'document_user_user', with: @user.name
        find("#document_user_user-dropdown .dropdown-item[data-value='#{@user.id}']").click

        find('#document_user_role-selectized').click
        find('.selectize-dropdown-content .option[data-value="responsible"]').click

        submit_form("button[type='submit']")

        base_selector = 'table tbody tr:nth-child(1)'
        assert_current_path users_document_members_path(@document)
        assert_selector base_selector, text: @user.name
        assert_selector base_selector, text: @user.email
      end

      should 'unsuccessfully' do
        submit_form("button[type='submit']")

        within('div.document_user_user') do
          assert_text(I18n.t('errors.messages.required'))
        end

        within('div.document_user_role') do
          assert_text(I18n.t('errors.messages.inclusion'))
        end
      end
    end

    should 'remove a member' do
      du = create(:document_user, :collaborator)
      user = du.user
      document = du.document

      visit users_document_members_path(document)

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{users_document_remove_member_path(document, user)}'][data-method='delete']").click
        end
      end

      assert_current_path users_document_members_path(document)
      flash_message = User.model_name.human
      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.remove.m', resource_name: flash_message))

      within('table.table tbody') do
        refute_text user.name
        refute_selector "a[href='#{users_document_remove_member_path(document, user)}'][data-method='delete']"
      end
    end
  end
end
