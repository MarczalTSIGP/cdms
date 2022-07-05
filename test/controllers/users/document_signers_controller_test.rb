require 'test_helper'

class Users::DocumentSignersControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      @department = create(:department)
      @department.department_users.create(user: @user, role: :responsible)
      @document = create(:document, :certification, available_to_sign: true, department: @department)
      @document_user = create(:document_signer, document: @document, user: @user)
      sign_in @user
    end

    context 'sign document' do
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
  end
end
