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

  context '.from_csv' do
    should 'call new with args' do
      document = create(:document)
      double_service = Struct.new(:perform)
      tmp_file = Tempfile.new
      mock = Minitest::Mock.new
      mock.expect :call, double_service.new(perform: true), [file: tmp_file, document_id: document.id]
      CreateDocumentRecipientsFromCsv.stub :new, mock do
        DocumentRecipient.from_csv(tmp_file, document.id)
      end

      assert_mock mock
    end

    should 'call perform from instance' do
      document = create(:document)
      mock = Minitest::Mock.new
      mock.expect :perform, true
      CreateDocumentRecipientsFromCsv.stub :new, mock do
        DocumentRecipient.from_csv(Tempfile.new, document.id)
      end

      assert_mock mock
    end
  end
end
