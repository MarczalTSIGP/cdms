require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'audience_members' do
    setup do
      user = create(:user, :manager)
      login_as(user, as: :user)
    end

    should 'list all' do
      audience_members = create_list(:audience_member, 3)
      visit admins_audience_members_path

      within('table.table tbody') do
        audience_members.each_with_index do |audience_member, index|
          child = index + 1
          base_selector = "tr:nth-child(#{child})"

          assert_selector "#{base_selector} a[href='#{admins_audience_member_path(audience_member)}']",
                          text: audience_member.name
          assert_selector base_selector, text: audience_member.email
          assert_selector base_selector, text: audience_member.cpf

          assert_selector "#{base_selector} a[href='#{edit_admins_audience_member_path(audience_member)}']"
          href = admins_audience_member_path(audience_member)

          assert_selector "#{base_selector} a[href='#{href}'][data-method='delete']"
        end
      end
    end

    should 'search' do
      first_name = 'Eduardo'
      second_name = 'Gustavo'

      FactoryBot.create(:audience_member, name: first_name)
      FactoryBot.create(:audience_member, name: second_name)

      visit admins_audience_members_path

      fill_in 'search', with: second_name
      submit_form('button.submit-search')

      assert_selector 'tr:nth-child(1) a', text: second_name
    end

    should 'display' do
      visit admins_audience_members_path

      assert_selector '#main-content .card-header', text: I18n.t('activerecord.models.audience_member.other')
      assert_selector "#main-content a[href='#{new_admins_audience_member_path}']",
                      text: I18n.t('views.audience_member.links.new')
    end
  end
end
