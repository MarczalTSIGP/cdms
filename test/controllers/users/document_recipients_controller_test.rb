require 'test_helper'

class Users::DocumentRecipientsControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      @department = create(:department)
      @document = create(:document, :certification, department: @department)
      @non_existent_cpf = '01234567890'
      @document_signer = create(:document_signer, document_id: @document.id)

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
        assert_difference('DocumentRecipient.all.count', 1) do
          post users_document_add_recipient_path(@document.id, @user.cpf)
        end

        assert_redirected_to users_document_recipients_path
        assert_equal I18n.t('flash.actions.add.m', resource_name: I18n.t('views.document.recipients.name')),
                     flash[:success]
      end

      should 'unsuccessfully' do
        post users_document_add_recipient_path(@document.id, @user.cpf)
        post users_document_add_recipient_path(@document.id, @user.cpf)

        assert_equal I18n.t('flash.actions.add.errors.not'),
                     flash[:error]

        assert_equal 1, @document.recipients.all.count
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

        assert 1, @document.recipients.all.count
      end
    end

    context 'add or remove recipient when document is signed' do
      setup do
        @document_signer.sign
        @flash = I18n.t('flash.actions.add_recipients.non')
      end

      should 'not redirect to users_documents_path when try access list page' do
        get users_document_recipients_path(@document)
        assert_response 200
      end

      should 'redirect to users_documents_path when try access new page' do
        get users_new_recipient_document_path(@document)

        assert_response 302
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.add_recipients.non'), flash[:warning]
      end

      should 'redirect to users_documents_path when post data to add' do
        assert_no_difference('DocumentRecipient.count') do
          post users_document_add_recipient_path(@document.id, @user.cpf)
        end

        assert_response 302
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.add_recipients.non'), flash[:warning]
      end

      should 'redirect to users_documents_path when delete' do
        create(:document_recipient, document: @document, cpf: @user.cpf,
                                    profile_id: @user.id, profile_type: @user.class.name)

        assert_no_difference('DocumentRecipient.count') do
          delete users_document_remove_recipient_path(@document.id, @user.cpf)
        end

        assert_response 302
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.add_recipients.non'), flash[:warning]
      end
    end
  end
end
