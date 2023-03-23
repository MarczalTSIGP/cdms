require 'application_system_test_case'

class EditProfileTest < ApplicationSystemTestCase
  should 'updates with success when the data are valid' do
    user = create(:user, :manager)
    login_as(user, scope: :user)

    visit edit_user_registration_path

    new_email = 'email@email.com'
    new_name = 'new name'

    fill_in 'user_name', with: new_name
    fill_in 'user_email', with: new_email
    fill_in 'user_current_password', with: user.password

    submit_form

    assert_current_path edit_user_registration_path
    assert_selector('div.alert.alert-info', text: I18n.t('devise.registrations.updated'))

    within('div.header a.nav-link') do
      assert_text new_name
      assert_text new_email
    end

    assert_field 'user_name', with: new_name
    assert_field 'user_email', with: new_email
  end

  should 'not update with invalid data' do
    user = create(:user)
    login_as(user, scope: :user)

    visit edit_user_registration_path

    fill_in 'user_name', with: ''
    fill_in 'user_email', with: 'email'
    fill_in 'user_current_password', with: user.password

    submit_form

    assert_selector('div.alert.alert-danger', text: I18n.t('simple_form.error_notification.default_message'))

    within('div.user_name') do
      assert_text(I18n.t('errors.messages.blank'))
    end
    within('div.user_email') do
      assert_text(I18n.t('errors.messages.invalid'))
    end
    within('div.user_current_password') do
      key = 'devise.registrations.edit.current_password_to_confirm'

      assert_text(I18n.t(key))
    end
  end
end
