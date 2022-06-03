require 'test_helper'

class Users::DocumentRecipientsControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      @department = create(:department)
      @document = create(:document, :certification, department: @department)
      @non_existent_cpf = '01234567890'

      sign_in @user
    end

    should 'get index' do
      get users_document_recipients_path(@document.id)
      assert_response :success

      assert_active_link(href: users_documents_path)

      assert_breadcrumbs({ link: users_root_path, text: I18n.t('views.breadcrumbs.home') },
                         { link: users_documents_path, text: Document.model_name.human(count: 2) },
                         { link: users_document_path(@document), text: I18n.t('views.breadcrumbs.show',
                                                                              model: Document.model_name.human,
                                                                              id: @document.id) },
                         { text: I18n.t('views.document.recipients.plural') })
    end

    should 'get new' do
      get users_new_recipient_document_path(@document.id)
      assert_response :success

      assert_active_link(href: users_documents_path)

      assert_breadcrumbs({ link: users_root_path, text: I18n.t('views.breadcrumbs.home') },
                         { link: users_documents_path, text: Document.model_name.human(count: 2) },
                         { link: users_document_path(@document), text: I18n.t('views.breadcrumbs.show',
                                                                              model: Document.model_name.human,
                                                                              id: @document.id) },
                         { link: users_document_recipients_path, text: I18n.t('views.document.recipients.plural') })
    end

    context 'add recipient' do
      should 'add' do
        assert_difference('DocumentRecipient.count', 1) do
          post users_document_add_recipient_path(@document.id, @user.cpf)
        end

        assert_redirected_to users_document_recipients_path
        assert_equal I18n.t('flash.actions.add.m', resource_name: I18n.t('views.document.recipients.name')),
                     flash[:success]
      end

      should 'unsuccessfully' do
        post users_document_add_recipient_path(@document.id, @user.cpf)
        post users_document_add_recipient_path(@document.id, @user.cpf)

        assert_equal I18n.t('flash.actions.errors'),
                     flash[:error]

        assert_equal 1, @document.recipients.count
      end
    end

    context 'remove recipient' do
      should 'remove' do
        create(:document_recipient, document: @document, cpf: @user.cpf,
                                    profile_id: @user.id, profile_type: @user.class.name)

        assert_difference('DocumentRecipient.count', -1) do
          delete users_document_remove_recipient_path(@document.id, @user.cpf)
        end

        assert_redirected_to users_document_recipients_path
        assert_equal I18n.t('flash.actions.destroy.m',
                            resource_name: I18n.t('views.document.recipients.name')), flash[:success]
      end

      should 'unsuccessfully' do
        create(:document_recipient, document: @document, cpf: @user.cpf,
                                    profile_id: @user.id, profile_type: @user.class.name)

        delete users_document_remove_recipient_path(@document.id, @non_existent_cpf)

        assert 1, @document.recipients.count
      end
    end
  end
end
