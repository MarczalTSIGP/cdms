require 'test_helper'

class SendEmailsTest < ActionMailer::TestCase
  def setup
    @signers = DocumentSigner.where(signed: false).group_by(&:document_id)
  end 
  
  test 'check if email was sent' do 
    assert_emails @signers.length do
      SendEmails.new().perform
    end
  end
end