require 'test_helper'

class DocumentRecipientTest < ActiveSupport::TestCase
  context 'validations' do
    subject { create(:document_recipient, :user) }
    should validate_uniqueness_of(:cpf).scoped_to(:document_id).case_insensitive
  end

  context 'relationships' do
    should belong_to(:document)
    should belong_to(:profile)
  end
end
