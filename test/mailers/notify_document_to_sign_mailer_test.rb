require 'test_helper'

class NotifyDocumentToSignMailerTest < ActionMailer::TestCase
  def setup 
    department = create(:department)
    @signer = create(:user)
    @document = create(:document, :declaration, department: department)
  end
  
  test "notify_sign" do
    email = NotifyDocumentToSignMailer.with(user_id: @signer.id, document: @document).notify_sign
    assert_emails 1 do 
      email.deliver_later
    end

    assert_equal email.to, [@signer.email]
    assert_equal email.from, ['sgcd@utfpr.edu.br']
    assert_equal email.subject, 'Documento para assinar'
    assert_match "Olá #{@signer.name}!\n\nVocê tem um novo documento para assinar\n\nIr para o documento", email.body.encoded
  end
end
