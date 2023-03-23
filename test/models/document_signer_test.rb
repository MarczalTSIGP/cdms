require 'test_helper'

class DocumentSignerTest < ActiveSupport::TestCase
  context 'documents to sign' do
    setup do
      @user = create(:user)
      @document_signer = create_list(:document_signer, 2).first
    end

    should 'sign the document and copy data' do
      @document_signer.sign

      assert_equal 1, DocumentSigner.signed.count

      @document_signer.reload

      assert_equal @document_signer.signer_role, @document_signer.document_role.name
      assert_not_nil @document_signer.signed_datetime
    end
  end

  should '.unsigned' do
    ds = create_list(:document_signer, 3, signed: false)

    assert_equal 3, DocumentSigner.unsigned.count

    ds.first.sign

    assert_equal 2, DocumentSigner.unsigned.count
  end
end
