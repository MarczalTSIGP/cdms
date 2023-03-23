require 'test_helper'

class Users::DocumentSignersControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      @department = create(:department)
      @department.department_users.create(user: @user, role: :responsible)
      @document = create(:document, :certification, available_to_sign: true, department: @department)
      sign_in @user
    end

    context 'sign document' do
      setup do
        @document_user = create(:document_signer, document: @document, user: @user)
      end

      should 'successfuly' do
        assert_equal 1, @user.unsigned_documents.count

        patch users_sign_document_path(@document),
              params: { user: { password: @user.password } }

        assert_equal 0, @user.unsigned_documents.count
        assert_equal I18n.t('flash.actions.sign.m', resource_name: I18n.t('views.document.name.singular')),
                     flash[:success]
      end

      should 'unsuccessfully' do
        assert_equal 1, @user.unsigned_documents.count

        incorrect_password = 'aRandomPass'
        patch users_sign_document_path(@document.id),
              params: { user: { password: incorrect_password } }, xhr: true

        assert_equal 1, @user.unsigned_documents.count
        assert_equal I18n.t('flash.actions.sign.errors.incorrect_password'), flash[:error]
      end
    end

    context 'signers' do
      setup do
        @document_role = create(:document_role)
      end

      should 'get signers' do
        get users_document_signers_path(@document)

        assert_response :success
        assert_active_link(href: users_documents_path)
      end

      context 'add' do
        should 'successfully' do
          params = { user_id: @user.id, document_id: @document.id, document_role: @document_role.id }

          assert_difference('DocumentSigner.count', 1) do
            post users_document_add_signer_path(@document), params: { document_signer: params }
          end

          assert_redirected_to users_document_signers_path(@document)
          assert_equal I18n.t('flash.actions.add.m', resource_name: User.model_name.human), flash[:success]
          @document.reload

          assert_equal 1, @document.signers.count
          follow_redirect!

          assert_active_link(href: users_documents_path)
        end

        should 'unsuccessfully with no signers' do
          params = { document_signer: { user_id: '', document_role: '' } }
          post users_document_add_signer_path(@document), params: params

          assert_response :success
          @document.reload

          assert_equal 0, @document.signers.count
        end

        should 'unsuccessfully with signers' do
          create(:document_signer, user: @user, document: @document, document_role: @document_role)
          params = { document_signer: { user_id: '', document_role: '' } }
          post users_document_add_signer_path(@document), params: params

          assert_response :success
          @document.reload

          assert_equal 1, @document.signers.count
        end
      end

      should 'remove' do
        document_signer = create(:document_signer, user: @user, document: @document, document_role: @document_role)

        assert_difference('DocumentSigner.count', -1) do
          delete users_document_remove_signer_path(@document, document_signer.user)
        end

        assert_redirected_to users_document_signers_path(@document)
      end
    end
  end

  context 'unauthenticated' do
    should 'redirect to login when not authenticated' do
      assert_redirect_to(unauthenticated_requests, new_user_session_path)
    end
  end

  private

  def unauthenticated_requests
    {
      get: [users_document_signers_path(1)],
      post: [users_document_add_signer_path(1)],
      patch: [users_sign_document_path(1)],
      delete: [users_document_remove_signer_path(1, 1)]
    }
  end
end
