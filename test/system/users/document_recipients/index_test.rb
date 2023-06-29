require 'application_system_test_case'

class IndexTest < ApplicationSystemTestCase
  context 'document_recipients:index' do
    setup do
      @user = create(:user)
      @audience_member = create(:audience_member)
      department = create(:department)
      department.department_users.create(user: @user)
      @document = create(:document, :certification, department: department)

      login_as(@user, as: :user)
    end

    should 'display' do
      visit users_document_recipients_path(@document.id)

      assert_selector '#main-content .card-header', text: @document.title
      assert_selector '.card-body .btn', text: I18n.t('views.document.recipients.new')
      assert_selector ".card-body .btn[href='#{users_new_recipient_document_path(@document.id)}']"
    end

    context 'list' do
      setup do
        document_recipient1 = create(:document_recipient, document: @document, cpf: @user.cpf,
                                                          profile_id: @user.id, profile_type: @user.class.name)

        document_recipient2 = create(:document_recipient, document: @document, cpf: @audience_member.cpf,
                                                          profile_id: @audience_member.id,
                                                          profile_type: @audience_member.class.name)

        @document_recipients = []

        @document_recipients.push(document_recipient1)
        @document_recipients.push(document_recipient2)
      end

      should 'all recipients of the document' do
        visit users_document_recipients_path(@document.id)

        @document.variables = [{ 'name' => 'Curso', 'identifier' => 'curso' }]
        @document.save

        within('table.table tbody') do
          @document_recipients.each_with_index do |recipient, index|
            child = index + 1
            base_selector = "tr:nth-child(#{child})"

            assert_selector base_selector, text: recipient.profile.name
            assert_selector base_selector, text: recipient.profile.cpf
            assert_selector base_selector, text: recipient.profile.email

            recipient.variables.each do |variable|
              assert_selector base_selector, text: "#{variable['name'].upcase} (#{variable['identifier']})".upcase
            end

            href = users_document_remove_recipient_path(@document.id, recipient.cpf)

            assert_selector "#{base_selector} a[href='#{href}']"
          end
        end
      end

      should 'remove a recipient from the list' do
        visit users_document_recipients_path(@document.id)

        base_selector = 'table tbody tr:nth-child(1)'

        find("#{base_selector} a").click
        page.driver.browser.switch_to.alert.accept

        assert_selector('div.alert.alert-success',
                        text: I18n.t('flash.actions.destroy.m',
                                     resource_name: I18n.t('views.document.recipients.name')))
      end
    end
  end
end
