require 'test_helper'

class Logics::Document::SignerTest < ActiveSupport::TestCase
  setup do 
    @lgs = Logics::Document::Signer.new
    @signers = DocumentSigner.where(signed: false).group_by(&:document_id)
  end

  test 'search_for_recipients' do
    lds_signers = @lgs.search_for_recipients

    assert @signers, lds_signers 
  end

  test 'get_emails' do
    # não consegui pensar em como fazer esse teste
  end
end