require 'test_helper'

class NotifyDocumentToSignMailerTest < ActionMailer::TestCase
  def setup
    @signer = create(:user)
    @document = create(:document, :declaration)
  end

  test 'notify_sign' do
    email = NotifyDocumentToSignMailer.with(emails: @signer.email, document: @document).notify_sign
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal email.to, [@signer.email]
    assert_equal ['sgcd@utfpr.edu.br'], email.from
    assert_equal 'Documento para assinar', email.subject
    assert_match 'tem um novo documento para assinar', email.body.encoded
  end
end
