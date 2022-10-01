require 'test_helper'

class DocumentSignerTest < ActiveSupport::TestCase
  context 'documents to sign' do
    setup do
      @user = create(:user)
      @document_signer = create(:document_signer)
    end

    should 'sign the document and copy data' do
      @document_signer.sign
      assert_equal 1, DocumentSigner.where(signed: true).count

      @document_signer.reload
      assert_equal @document_signer.signer_role, @document_signer.document_role.name
      assert_not_nil @document_signer.signed_datetime
    end
  end
end
