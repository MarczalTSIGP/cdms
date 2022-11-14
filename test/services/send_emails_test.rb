require 'test_helper'

class SendEmailsTest < ActionMailer::TestCase
  def setup
    ds = create_list(:document_signer, 4)
    ds.first.sign
  end

  test 'check if email was sent' do
    assert_emails 3 do
      SendEmails.perform
    end
  end
end
