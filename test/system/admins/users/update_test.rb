require 'application_system_test_case'

class UpdateTest < ApplicationSystemTestCase
  context 'update' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)

      @user = create(:user, active: false)
      visit edit_admins_user_path(@user)
    end

    should 'fill the fields' do
      assert_field 'user_name', with: @user.name
      assert_field 'user_username', with: @user.username
      assert_field 'user_cpf', with: @user.cpf
      assert_field 'user_register_number', with: @user.register_number
      assert_unchecked_field 'user_active', visible: false
    end

    context 'successfully' do
      should 'no image' do
        user = build(:user, active: true)

        fill_in 'user_name', with: user.name
        fill_in 'user_cpf', with: user.cpf
        fill_in 'user_username', with: user.username
        fill_in 'user_register_number', with: user.register_number
        find('div.user_active label.custom-switch').click
        submit_form

        flash_message = I18n.t('flash.actions.update.m', resource_name: User.model_name.human)

        assert_selector('div.alert.alert-success', text: flash_message)

        within('table.table tbody') do
          assert_selector "a[href='#{admins_user_path(@user)}']", text: user.name
          assert_text user.email
          assert_text user.username
          assert_text user.register_number
          assert_text user.cpf
          assert_text I18n.t("views.status.#{user.active}")
        end

        visit admins_user_path(@user)

        assert_selector "img[src='#{@user.avatar.url}']"
      end

      should 'image' do
        attach_file 'user_avatar', FileHelper.image.path, make_visible: true
        submit_form

        @user.reload
        visit admins_user_path(@user)

        assert_selector "img[src='#{@user.avatar.url}']"
      end
    end

    should 'unsuccessfully' do
      fill_in 'user_name', with: ''
      fill_in 'user_cpf', with: ''
      fill_in 'user_username', with: ''
      fill_in 'user_register_number', with: ''
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
    end
  end
end
