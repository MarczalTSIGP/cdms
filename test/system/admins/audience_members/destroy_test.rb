require 'application_system_test_case'

class DestroyTest < ApplicationSystemTestCase
  context 'audience_member' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
    end

    should 'destroy a audience_member' do
      audience_member = create(:audience_member)
      visit admins_audience_members_path

      within('#main-content table.table tbody') do
        accept_confirm do
          find("a[href='#{admins_audience_member_path(audience_member)}'][data-method='delete']").click
        end
      end

      assert_current_path admins_audience_members_path
      flash_message = I18n.t('activerecord.models.audience_member.one')

      assert_selector('div.alert.alert-success',
                      text: I18n.t('flash.actions.destroy.m', resource_name: flash_message))

      within('table.table tbody') do
        refute_text audience_member.name
        refute_selector "a[href='#{edit_admins_audience_member_path(audience_member)}']"
        refute_selector "a[href='#{admins_audience_member_path(audience_member)}'][data-method='delete']"
      end
    end
  end
end
