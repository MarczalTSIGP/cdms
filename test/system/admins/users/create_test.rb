require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
      visit new_admins_user_path
    end

    context 'successfully' do
      should 'no image' do
        user = build(:user)

        fill_in 'user_name', with: user.name
        fill_in 'user_cpf', with: user.cpf
        fill_in 'user_username', with: user.username
        fill_in 'user_register_number', with: user.register_number
        find('div.user_active label.custom-switch').click
        fill_in 'user_password', with: user.password
        fill_in 'user_password_confirmation', with: user.password
        submit_form

        flash_message = I18n.t('flash.actions.create.m', resource_name: User.model_name.human)

        assert_selector('div.alert.alert-success', text: flash_message)

        user = User.last
        within('table.table tbody') do
          assert_selector "a[href='#{admins_user_path(user)}']", text: user.name
          assert_text user.email
          assert_text user.username
          assert_text user.register_number
          assert_text user.cpf
          assert_text I18n.t("views.status.#{user.active?}")

          assert_selector "a[href='#{edit_admins_user_path(user)}']"
          assert_selector "a[href='#{admins_user_path(user)}'][data-method='delete']"
        end
      end

      should 'with image' do
        user = build(:user)

        fill_in 'user_name', with: user.name
        fill_in 'user_cpf', with: user.cpf
        fill_in 'user_username', with: user.username
        fill_in 'user_register_number', with: user.register_number
        fill_in 'user_password', with: user.password
        fill_in 'user_password_confirmation', with: user.password
        attach_file 'user_avatar', FileHelper.image.path, make_visible: true
        submit_form

        user = User.last
        visit admins_user_path(user)

        assert_selector "img[src='#{user.avatar.url}']"
      end
    end

    should 'unsuccessfully' do
      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.user_name') do
        assert_text I18n.t('errors.messages.blank')
      end

      within('div.user_username') do
        assert_text I18n.t('errors.messages.invalid')
      end

      within('div.user_register_number') do
        assert_text I18n.t('errors.messages.blank')
      end

      within('div.user_cpf') do
        assert_text I18n.t('errors.messages.invalid')
      end

      within('div.user_name') do
        assert_text I18n.t('errors.messages.blank')
      end

      within('div.user_password') do
        assert_text I18n.t('errors.messages.blank')
      end
    end
  end
end
