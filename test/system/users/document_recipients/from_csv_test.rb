require 'application_system_test_case'
require 'csv'

class FromCsvTest < ApplicationSystemTestCase
  context 'document_recipients:index' do
    setup do
      @user = create(:user)
      @audience_member = create(:audience_member)
      department = create(:department)
      department.department_users.create(user: @user)
      @document = create(:document, :certification, department: department)

      login_as(@user, as: :user)
    end

    context 'before import from csv' do
      should 'display buttons sucessufuly' do
        visit users_new_document_recipients_from_csv_path(@document.id)

        assert_selector '#main-content .card-header',
                        text: I18n.t('views.document.recipients.nwdp', name: @document.title)
        assert_selector '.card-body .btn', text: I18n.t('views.document.recipients.import.btn_csv')
        assert_selector '.card-body .btn', text: I18n.t('views.document.recipients.import.btn_download_sample_file')
      end
    end

    context 'after import from csv' do
      context 'unsuccessfully' do
        should ' no file - display blank alert ' do
          visit users_new_document_recipients_from_csv_path(@document.id)
          find('.card-body .btn', text: I18n.t('views.document.recipients.import.btn_csv')).click

          assert_selector '.card-body .alert', text: I18n.t('flash.actions.import.errors.blank')
        end

        should ' invalid file - display blank alert ' do
          csv_rows = CSV.generate(headers: true) do |csv|
            csv << ['abc']
          end

          file = Tempfile.new(['test_file', '.csv'])
          file.write(csv_rows)
          file.rewind

          visit users_new_document_recipients_from_csv_path(@document.id)
          attach_file(:csv_file, file.path, visible: false)
          find('.card-body .btn', text: I18n.t('views.document.recipients.import.btn_csv')).click

          assert_selector '.card-body .alert', text: I18n.t('flash.actions.import.errors.invalid')
        end
      end

      context 'successfully' do
        should ' valid file - display @results ' do
          @document.variables = [{ 'name' => 'Curso', 'identifier' => 'curso' }]
          @document.save

          file = create_temp_file(generate_valid_csv_data)

          visit users_new_document_recipients_from_csv_path(@document.id)
          attach_file(:csv_file, file.path, visible: false)
          find('.card-body .btn', text: I18n.t('views.document.recipients.import.btn_csv')).click

          assert_selector '.card-body .alert',
                          text: I18n.t('flash.actions.import.m',
                                       resource_name: I18n.t('activerecord.models.document_recipients.other'))

          assert_selector '#document_recipients_registered',
                          text: I18n.t('views.document.recipients.import.document_recipients_registered')
          assert_selector '#invalids', text: I18n.t('views.document.recipients.import.invalids')
          # considere that exist at least one invalid member.

          find('#document_recipients_registered > div.card-header > div > a').click
          find('#invalids > div.card-header > div > a').click

          assert_selector '#document_recipients_registered > div.card-body > table > thead > tr > th',
                          text: User.human_attribute_name(:name).upcase
          assert_selector '#document_recipients_registered > div.card-body > table > thead > tr > th',
                          text: User.human_attribute_name(:cpf)
          assert_selector '#document_recipients_registered > div.card-body > table > thead > tr > th',
                          text: User.human_attribute_name(:email).upcase

          @document.variables.each do |variable|
            assert_selector '#document_recipients_registered > div.card-body > table > thead > tr > th',
                            text: "#{variable['name'].upcase} (#{variable['identifier'].upcase})"
          end
        end
      end
    end
  end

  def generate_valid_csv_data
    CSV.generate(headers: true) do |csv|
      csv << %w[name email cpf]
      csv << ['Nome exemplo', 'email@exemplo.com', '382.528.560-04'] # valid audience member
      csv << ['Nome exemplo2', 'email2@exemplo.com', '574.961.619-34'] # valid audience member
      csv << ['Nome exemplo2', 'email3@exemplo.com', '068.674.529-57'] # invalid audience member due cpf
      csv << ['Lucas', 'lucasgeron@utfpr.edu.br', '068.674.579-59'] # valid user
    end
  end

  def create_temp_file(data)
    file = Tempfile.new(['test_file', '.csv'])
    file.write(data)
    file.rewind
    file
  end
end
