require 'test_helper'
class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @document_recipient = create(:document_recipient, :user)
  end

  context 'public' do
    should 'get show with valid code' do
      get show_document_path(@document_recipient.verification_code)

      assert_response :success
      assert_equal(I18n.t('views.documents.valid_code', code: @document_recipient.verification_code), flash[:success])
    end

    should 'get show with invalid code' do
      get show_document_path('invalid_code')

      assert_redirected_to documents_path
      assert_equal(I18n.t('views.documents.not_exist_document', code: 'invalid_code'), flash[:warning])
    end

    should 'post index' do
      post document_code_path(@document_recipient.verification_code)

      assert_response :success
    end

    should 'post index without document code' do
      post documents_path, params: { document: { code: '' } }

      assert_redirected_to documents_path
      assert_equal(I18n.t('views.documents.invalid_code'), flash[:warning])
    end
  end
end
