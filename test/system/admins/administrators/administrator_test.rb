require 'application_system_test_case'

class Admins::AdministratorTest < ApplicationSystemTestCase
  context 'administrators' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)
    end

    context 'create' do
      setup do
        @manager = create(:role_manager)
        create(:role_assistant)
        @user = create(:user)
        visit admins_administrators_path
      end

      should 'successfully' do
        fill_in 'administrator_user', with: @user.name
        find("#administrator_user-dropdown .dropdown-item[data-value='#{@user.id}']").click

        find_by_id('administrator_role_id-selectized').click
        find(".selectize-dropdown-content .option[data-value='#{@manager.id}']").click

        submit_form("button[type='submit']")

        @user.reload
        base_selector = 'table tbody tr:nth-child(2)'

        assert_selector "#{base_selector} a[href='#{admins_user_path(@user)}']", text: @user.name
        assert_selector base_selector, text: @user.email
        assert_selector base_selector, text: @user.username
        assert_selector base_selector, text: @user.register_number
        assert_selector base_selector, text: I18n.t("views.status.#{@user.active?}")
        assert_selector base_selector, text: @user.role.name
        assert_selector "#{base_selector} a[href='#{admins_administrator_path(@user)}'][data-method='delete']"
      end

      should 'unsuccessfully' do
        submit_form("button[type='submit']")

        within('div.administrator_user') do
          assert_text(I18n.t('errors.messages.blank'))
        end

        within('div.administrator_role_id') do
          assert_text(I18n.t('errors.messages.blank'))
        end
      end
    end

    should 'destroy' do
      user = create_list(:user, 2, :manager).first
      visit admins_administrators_path

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{admins_administrator_path(user)}'][data-method='delete']").click
        end
      end

      assert_current_path admins_administrators_path

      within('table.table tbody') do
        refute_text user.name
        refute_selector "a[href='#{admins_administrator_path(user)}'][data-method='delete']"
      end
    end
  end
end
