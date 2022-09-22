require 'test_helper'

class NotifyDocumentToSignMailerTest < ActionMailer::TestCase
  def setup
    @signer = create(:user)
    @document = create(:document, :declaration)
  end
  
  test 'notify_sign' do
    email = NotifyDocumentToSignMailer.with(user_id: @signer.id, document: @document).notify_sign
    assert_emails 1 do
      email.deliver_later
    end

    assert_equal email.to, [@signer.email]
    assert_equal email.from, ['sgcd@utfpr.edu.br']
    assert_equal email.subject, 'Documento para assinar'
    assert_match 'tem um novo documento para assinar', email.body.encoded
  end
end
