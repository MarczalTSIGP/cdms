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

    should 'get preview' do
      get users_preview_document_path(@document)
      assert_response :success
    end

    context '#edit' do
      should 'unsuccessfully' do
        create(:document_signer, document: @document, signed: true)

        get edit_users_document_path(@document)

        assert_redirected_to(users_documents_path)
        assert_equal I18n.t('flash.actions.edit.non'), flash[:warning]
        follow_redirect!
        assert_active_link(href: users_documents_path)
      end

      should 'successfully' do
        get edit_users_document_path(@document)
        assert_response :success
        assert_active_link(href: users_documents_path)
      end
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
