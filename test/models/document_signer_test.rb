require 'test_helper'

class DocumentSignerTest < ActiveSupport::TestCase
  context 'documents to sign' do
    setup do
      @user = create(:user)
      @document_signer = create(:document_signer)
    end

    should 'return document signed' do
      role_signer = @document_signer.document_role.name
      @document_signer.sign(role_signer)
      assert_equal 1, @document_signer.signed_documents.size
    end
  end
end
