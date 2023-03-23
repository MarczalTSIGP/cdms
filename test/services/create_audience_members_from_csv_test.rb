require 'test_helper'
require 'csv'

class CreateAudienceMembersFromCsvTest < ActiveSupport::TestCase
  should 'import from csv' do
    csv = csv_file
    result = nil

    assert_difference('AudienceMember.count', 3) do
      result = CreateAudienceMembersFromCsv.new(file: csv).perform
    end

    assert_equal 3, result.registered.count, 'be inserted by resp'
    assert_equal 2, result.duplicates.count, 'be duplicates'
    assert_equal 3, result.invalids.count, 'be invalids'
  end

  should 'valid file extension' do
    file = Tempfile.new(['ads', '.pdf'])
    result = CreateAudienceMembersFromCsv.new(file: file).perform

    assert_not result.valid_file?, 'Invalid file'
  end

  private

  # rubocop:disable Metrics/AbcSize
  def members
    ams = build_list(:audience_member, 3)

    # duplications
    am = ams.last
    ams << build(:audience_member, cpf: am.cpf)
    ams << build(:audience_member, email: am.email)

    # already registered
    am = create(:audience_member)
    ams << build(:audience_member, cpf: am.cpf)
    ams << build(:audience_member, email: am.email)

    # invalids
    ams << build(:audience_member, name: '')
    ams << build(:audience_member, email: 'email')
    ams << build(:audience_member, cpf: '0422')
  end
  # rubocop:enable Metrics/AbcSize

  def csv_file
    file = Tempfile.new(['ads', '.csv'])

    CSV.open(file, 'w') do |csv|
      csv << attribute_names

      members.each do |ad|
        csv << [ad.name, ad.email, ad.cpf]
      end
    end
    file
  end

  def attribute_names
    attribute_names = AudienceMember.attribute_names.dup
    attribute_names.delete_if { |a| a =~ /id|created_at|updated_at/i }
  end
end
