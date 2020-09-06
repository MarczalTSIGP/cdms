require 'application_system_test_case'

class DestroyTest < ApplicationSystemTestCase
  context 'user' do
    setup do
      admin = create(:admin)
      login_as(admin, scope: :admin)
    end

    should 'destroy a user' do
      user = create(:user)
      visit admins_users_path

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{admins_user_path(user)}'][data-method='delete']").click
        end
      end

      assert_current_path admins_users_path

      within('table.table tbody') do
        refute_text user.name
        refute_selector "a[href='#{edit_admins_user_path(user)}']"
        refute_selector "a[href='#{admins_user_path(user)}'][data-method='delete']"
      end
    end
  end
end
