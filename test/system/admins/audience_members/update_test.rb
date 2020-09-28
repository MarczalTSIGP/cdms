require 'application_system_test_case'

class UpdateTest < ApplicationSystemTestCase
  context 'update' do
    setup do
      admin = create(:admin)
      login_as(admin, scope: :admin)

      @audience_member = create(:audience_member)
      visit edit_admins_audience_member_path(@audience_member)
    end

    should 'fill the fields' do
      assert_field 'audience_member_name', with: @audience_member.name
      assert_field 'audience_member_email', with: @audience_member.email
      assert_field 'audience_member_cpf', with: @audience_member.cpf
    end

    should 'successfully' do
      audience_member = build(:audience_member)

      fill_in 'audience_member_name', with: audience_member.name
      fill_in 'audience_member_email', with: audience_member.email
      fill_in 'audience_member_cpf', with: audience_member.cpf
      fill_in 'audience_member_password', with: '123456'
      fill_in 'audience_member_password_confirmation', with: '123456'

      submit_form

      flash_message = I18n.t('flash.actions.update.m', resource_name: audience_member.model_name.human)
      assert_selector('div.alert.alert-success', text: flash_message)

      within('table.table tbody') do
        assert_selector "a[href='#{admins_audience_member_path(@audience_member)}']", text: audience_member.name
        assert_text audience_member.email
        assert_text audience_member.cpf
      end
    end

    should 'unsuccessfully' do
      fill_in 'audience_member_name', with: ''
      fill_in 'audience_member_email', with: ''
      fill_in 'audience_member_cpf', with: ''
      fill_in 'audience_member_password', with: ''
      fill_in 'audience_member_password_confirmation', with: ''

      submit_form

      assert_selector('div.alert.alert-danger', text: I18n.t('flash.actions.errors'))

      within('div.audience_member_name') do
        assert_text(I18n.t('errors.messages.blank'))
        assert_text(I18n.t('errors.messages.too_short', count: 2))
      end

      within('div.audience_member_email') do
        assert_text(I18n.t('errors.messages.invalid'))
      end

      within('div.audience_member_cpf') do
        assert_text(I18n.t('errors.messages.invalid'))
      end

      within('div.audience_member_password') do
        assert_text(I18n.t('errors.messages.blank'))
      end
    end
  end
end
