require 'application_system_test_case'

class CreateTest < ApplicationSystemTestCase
  context 'create' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
      visit new_admins_audience_member_path
    end

    should 'successfully' do
      audience_member = build(:audience_member)

      fill_in 'audience_member_name', with: audience_member.name
      fill_in 'audience_member_email', with: audience_member.email
      fill_in 'audience_member_cpf', with: audience_member.cpf

      submit_form

      flash_message = I18n.t('flash.actions.create.m', resource_name: audience_member.model_name.human)

      assert_selector('div.alert.alert-success', text: flash_message)

      audience_member = AudienceMember.last
      within('table.table tbody') do
        assert_selector "a[href='#{admins_audience_member_path(audience_member)}']", text: audience_member.name
        assert_text audience_member.email
        assert_text audience_member.cpf

        assert_selector "a[href='#{edit_admins_audience_member_path(audience_member)}']"
        assert_selector "a[href='#{admins_audience_member_path(audience_member)}'][data-method='delete']"
      end
    end

    should 'unsuccessfully' do
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
    end
  end
end
