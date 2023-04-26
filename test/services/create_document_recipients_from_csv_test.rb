require 'test_helper'
require 'csv'

class CreateDocumentRecipientsFromCsvTest < ActiveSupport::TestCase
  should 'import from csv' do
    @user = create(:user)
    @audience_member = create(:audience_member)
    department = create(:department)
    department.department_users.create(user: @user)
    @document = create(:document, :certification, department: department)

    csv = invalid_csv_file
    result = nil

    assert_no_difference('DocumentRecipient.count') do
      result = CreateDocumentRecipientsFromCsv.new(file: csv, document_id: @document.id).perform
    end

    csv = create_temp_file(generate_valid_csv_data)
    # p CSV.read(csv)

    assert_difference('DocumentRecipient.count', 3) do
      result = CreateDocumentRecipientsFromCsv.new(file: csv, document_id: @document.id).perform
    end

    assert_equal 3, result.document_recipients_registered.count, 'be inserted by resp'
    assert_equal 1, result.invalids.count, 'be invalids'
  end

  private

  def generate_valid_csv_data
    CSV.generate(headers: true) do |csv|
      csv << %w[name email cpf]
      csv << ['Nome exemplo', 'email@exemplo.com', '382.528.560-04'] # valid audience member
      csv << ['Nome exemplo2', 'email2@exemplo.com', '574.961.619-34'] # valid audience member
      csv << ['Nome exemplo2', 'email3@exemplo.com', '068.674.529-57'] # invalid audience member due cpf
      csv << ['Lucas', 'lucasgeron@utfpr.edu.br', '068.674.579-59'] # valid audience member - not user
    end
  end

  def create_temp_file(data)
    file = Tempfile.new(['valid_csv_file', '.csv'])
    file.write(data)
    file.rewind
    file # with 3 document_recipients_registered and 1 invalid
  end

  def invalid_csv_file
    csv_rows = CSV.generate(headers: true) do |csv|
      csv << %w[name email cpf]
    end

    file = Tempfile.new(['invalid_csv_file', '.csv'])
    file.write(csv_rows)
    file.rewind
    file
  end
end
