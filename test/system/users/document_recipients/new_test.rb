require 'application_system_test_case'

class NewTest < ApplicationSystemTestCase
  context 'document_recipients:new' do
    setup do
      @user = create(:user)
      @audience_member = create(:audience_member)
      department = create(:department)
      department.department_users.create(user: @user)
      @document = create(:document, :certification, department: department)
      @non_existent_cpf = '12345678901'

      login_as(@user, as: :user)
    end

    should 'display' do
      visit users_new_recipient_document_path(@document.id)

      assert_selector '#main-content .card-header', text: I18n.t('views.document.recipients.new')
      assert_selector ".card-body #search[data-url='#{users_search_non_recipient_path(@document.id)}']"
    end

    context 'add recipient' do
      should 'add' do
        visit users_new_recipient_document_path(@document.id)

        fill_in 'search', with: @user.cpf
        find('.card-body .submit-search').click

        base_selector = 'table tbody tr:nth-child(1)'

        assert_selector base_selector, text: @user.cpf
        assert_selector base_selector, text: @user.name
        assert_selector base_selector, text: @user.email

        find('table tbody .btn').click

        redirect_to users_document_recipients_path(@document.id)

        assert_selector('div.alert.alert-success',
                        text: I18n.t('flash.actions.add.m', resource_name: I18n.t('views.document.recipients.name')))

        base_selector = 'table tbody tr:nth-child(1)'

        assert_selector base_selector, text: @user.cpf
        assert_selector base_selector, text: @user.name
        assert_selector base_selector, text: @user.email

        href = users_document_add_recipient_path(@document.id, @user.cpf)
        assert_selector "#{base_selector} a[href='#{href}']"
      end

      should 'cpf does not exist in the database ' do
        visit users_new_recipient_document_path(@document.id)

        fill_in 'search', with: @non_existent_cpf
        find('.card-body .submit-search').click

        assert_selector('div.alert.alert-warning',
                        text: I18n.t('flash.not_found'))
      end

      should 'recipient already linked to the document' do
        create(:document_recipient, document: @document, cpf: @user.cpf,
                                    profile_id: @user.id, profile_type: @user.class.name)

        visit users_new_recipient_document_path(@document.id)

        fill_in 'search', with: @user.cpf
        find('.card-body .submit-search').click

        assert_selector('div.alert.alert-warning',
                        text: I18n.t('flash.actions.add.errors.exists',
                                     resource_name: I18n.t('views.document.recipients.name')))
      end
    end
  end
end
