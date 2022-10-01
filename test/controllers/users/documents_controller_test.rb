require 'test_helper'

class Users::DocumentsControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      @department = create(:department)
      @department.department_users.create(user: @user, role: :responsible)
      @document = create(:document, :certification, department: @department)
      @document_role = create(:document_role)
      sign_in @user
    end

    should 'get index' do
      get users_documents_path
      assert_response :success
      assert_active_link(href: users_documents_path)
    end

    should 'get new' do
      get new_users_document_path
      assert_response :success
      assert_active_link(href: users_documents_path)
    end

    should 'get edit' do
      get edit_users_document_path(@document)
      assert_response :success
      assert_active_link(href: users_documents_path)
    end

    should 'get preview' do
      get users_preview_document_path(@document)
      assert_response :success
    end

    context '#create' do
      should 'successfully' do
        assert_difference('Document.count', 1) do
          post users_documents_path, params: { document: attributes_for(:document, :declaration,
                                                                        department_id: @department.id) }
        end
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.create.m', resource_name: Document.model_name.human), flash[:success]
      end

      should 'unsuccessfully' do
        assert_no_difference('Document.count') do
          post users_documents_path, params: { document: attributes_for(:document, title: '') }
        end

        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]
      end
    end

    context '#update' do
      should 'successfully' do
        patch users_document_path(@document), params: { document: { title: 'updated' } }
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.update.m', resource_name: Document.model_name.human),
                     flash[:success]
        @document.reload
        assert_equal 'updated', @document.title
      end

      should 'unsuccessfully' do
        patch users_document_path(@document), params: { document: { title: '' } }
        assert_response :success
        assert_equal I18n.t('flash.actions.errors'), flash[:error]

        title = @document.title
        @document.reload
        assert_equal title, @document.title
      end
    end

    should 'destroy' do
      assert_difference('Document.count', -1) do
        delete users_document_path(@document)
      end
      assert_redirected_to users_documents_path
      assert_equal I18n.t('flash.actions.destroy.m', resource_name: Document.model_name.human), flash[:success]
    end

    context 'signers' do
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

  context 'authenticated with no departments' do
    setup do
      user = create(:user)
      sign_in user
    end

    should 'should redirect to index whe has no departments' do
      assert_redirect_to(non_member_requests, users_documents_path)
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
      get: [users_documents_path, new_users_document_path,
            edit_users_document_path(1), users_document_path(1)],
      post: [users_documents_path],
      patch: [users_document_path(1)],
      delete: [users_document_path(1)]
    }
  end

  def non_member_requests
    flash = { type: :warning, message: I18n.t('flash.actions.member.non') }
    {
      get: [{ route: new_users_document_path, flash: flash },
            { route: edit_users_document_path(1), flash: flash }],
      post: [{ route: users_documents_path, flash: flash }],
      patch: [{ route: users_document_path(1), flash: flash }],
      delete: [{ route: users_document_path(1), flash: flash }]
    }
  end
end
