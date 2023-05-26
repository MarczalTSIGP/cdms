require 'test_helper'

class Logics::Document::RecipientTest < ActiveSupport::TestCase
  setup do
    @document_recipient = create(:document_recipient, :user)
    @document = @document_recipient.document
    @user = @document_recipient.profile

    @recipient = Logics::Document::Recipient.new(@document.document_recipients)
  end

  context 'recipients' do
    should 'return all documents' do
      assert_equal 1, @recipient.all.size
      assert_includes @recipient.all, @document_recipient
    end

    should 'do not return recipients from other documents' do
      other_document = create(:document)
      other_document.recipients.add(create(:audience_member))

      assert_equal 1, @recipient.all.size
      assert_includes @recipient.all, @document_recipient
    end

    should 'find user by cpf' do
      user = create(:user)
      user_profile = Logics::Document::Recipient.find_by(cpf: user.cpf)

      assert_equal user, user_profile
    end

    should 'find audience_member by cpf' do
      am = create(:audience_member)
      am_profile = Logics::Document::Recipient.find_by(cpf: am.cpf)

      assert_equal am, am_profile
    end

    should 'return nil inf not found a recipient' do
      profile = Logics::Document::Recipient.find_by(cpf: '123.123.123-11')

      assert_nil profile
    end

    should 'add a recipient' do
      user = create(:user)
      am = create(:audience_member)

      @recipient.add(user.cpf)
      @recipient.add(am.cpf)

      recipients = @recipient.all.map(&:profile)

      assert_equal 3, recipients.size
      assert_includes recipients, user
      assert_includes recipients, am
    end

    should 'find a recipient' do
      user = create(:user)
      @recipient.add(user.cpf)

      recipient = @recipient.find_by(cpf: user.cpf)

      assert_equal user, recipient.profile
    end

    should 'not add a recipient twice' do
      assert_not @recipient.add(@user)
    end

    should 'remove a recipient' do
      user = create(:user)
      am = create(:audience_member)

      @recipient.add(user.cpf)
      @recipient.add(am.cpf)

      assert @recipient.remove(user.cpf)
      assert_equal 2, @recipient.all.size

      assert @recipient.remove(am.cpf)

      recipients = @recipient.all.map(&:profile)

      assert_equal 1, recipients.size
      assert_not_includes recipients, user
      assert_not_includes recipients, am
    end
  end
end
