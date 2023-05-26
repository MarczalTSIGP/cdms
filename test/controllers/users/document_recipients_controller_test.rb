require 'test_helper'
require 'tempfile'
require 'csv'

require 'active_support/all'

class Users::DocumentRecipientsControllerTest < ActionDispatch::IntegrationTest
  context 'authenticated' do
    setup do
      @user = create(:user)
      @department = create(:department)
      @document = create(:document, :certification, department: @department)
      @non_existent_cpf = '01234567890'
      @document_signer = create(:document_signer, document_id: @document.id)

      sign_in @user
    end

    should 'get index' do
      get users_document_recipients_path(@document.id)

      assert_response :success

      assert_active_link(href: users_documents_path)

      assert_breadcrumbs({ link: users_root_path, text: I18n.t('views.breadcrumbs.home') },
                         { link: users_documents_path, text: Document.model_name.human(count: 2) },
                         { link: users_document_path(@document), text: I18n.t('views.breadcrumbs.show',
                                                                              model: Document.model_name.human,
                                                                              id: @document.id) },
                         { text: I18n.t('views.document.recipients.plural') })
    end

    should 'get from_csv' do
      get users_new_document_recipients_from_csv_path(@document.id)

      assert_response :success

      # Pagina Inicial
      assert_breadcrumbs({ link: users_root_path, text: I18n.t('views.breadcrumbs.home') },
                         # Certificados/Declarações
                         { link: users_documents_path, text: Document.model_name.human(count: 2) },
                         # Certificado/Declaração #3
                         { link: users_document_path(@document),
                           text: I18n.t('views.breadcrumbs.show', model: Document.model_name.human, id: @document.id) },
                         # Destinatários
                         { link: users_document_recipients_path(@document),
                           text: I18n.t('views.document.recipients.plural') },
                         # Importar CSV
                         { text: I18n.t('views.document.recipients.import.btn_csv') })
    end

    should 'post from_csv' do
      csv_rows = CSV.generate(headers: true) do |csv|
        csv << %w[name email cpf]
        csv << ['Nome exemplo', 'email@exemplo.com', '382.528.560-04'] # valid audience member
        csv << ['Nome exemplo2', 'email2@exemplo.com', '574.961.619-34'] # valid audience member
        csv << ['Nome exemplo2', 'email3@exemplo.com', '068.674.529-57'] # invalid audience member due cpf
        csv << ['Lucas', 'lucasgeron@utfpr.edu.br', '068.674.579-59'] # valid user
      end

      file = Tempfile.new(['test_file', '.csv']) # create new temp file
      file.write(csv_rows) # white csv rows
      file.rewind # save file to disk

      uploaded_file = Rack::Test::UploadedFile.new(file.path, 'text/csv')
      # p CSV.read(uploaded_file) # print csv file

      assert_difference 'DocumentRecipient.count', 3 do
        post users_create_document_recipients_from_csv_path(@document.id),
             params: { csv: { file: uploaded_file }, headers: { 'CONTENT_TYPE' => 'multipart/form-data' } }
      end

      assert_response :success
      assert_equal I18n.t('flash.actions.import.m',
                          resource_name: I18n.t('activerecord.models.document_recipients.other')),
                   flash[:success]
      #  importados com sucesso!, Destinatários do Documento, as :success
    end

    should 'post from_csv unsuccessfully due invalid file' do
      csv_rows = CSV.generate(headers: true) do |csv|
        csv << ['abc']
      end

      file = Tempfile.new(['test_file', '.csv'])
      file.write(csv_rows)
      file.rewind

      uploaded_file = Rack::Test::UploadedFile.new(file.path, 'text/csv')

      assert_no_difference 'DocumentRecipient.count' do
        post users_create_document_recipients_from_csv_path(@document.id),
             params: { csv: { file: uploaded_file }, headers: { 'CONTENT_TYPE' => 'multipart/form-data' } }
      end

      assert_response :success
      assert_equal I18n.t('flash.actions.import.errors.invalid'), flash[:error]
    end

    should 'post from_csv unsuccessfully due no file' do
      post users_create_document_recipients_from_csv_path(@document.id)

      assert_response :success
      assert_equal I18n.t('flash.actions.import.errors.blank'), flash[:error]
    end

    should 'get download_csv' do
      # document.variables recebe uma array de jsons, em formato json.
      @document.variables = [{ 'name' => 'codigo', 'identifier' => 'cod' },
                             { 'name' => 'teste', 'identifier' => 'teste' }].to_json
      @document.save!

      # fazendo a requisição de download
      get users_document_recipients_download_csv_path(@document.id)

      assert_response :success
      assert_equal 'text/csv', response.content_type

      # verifica se existe um anexo na resposta, contendo o titulo do arquivo e a extensão .csv
      expected_title = "#{@document.title} - Modelo de Importação de Destinatários"
      normalized_str = ActiveSupport::Inflector.transliterate(expected_title)

      assert_match(/attachment; filename="#{normalized_str}.csv"/, response.headers['Content-Disposition'])

      # verifica se o arquivo para download foi montado corretamente
      variables = @document.variables.count.positive? ? ',' : ''
      @document.variables.each_with_index do |variable, index|
        variables << variable['identifier']
        variables << ',' if index < @document.variables.length - 1
      end

      # verifica se o corpo do arquivo é o esperado
      expected_csv_data = "name,email,cpf#{variables}\n"

      assert_equal expected_csv_data, response.body
    end

    should 'get new' do
      get users_new_recipient_document_path(@document.id)

      assert_response :success

      assert_active_link(href: users_documents_path)

      assert_breadcrumbs({ link: users_root_path, text: I18n.t('views.breadcrumbs.home') },
                         { link: users_documents_path, text: Document.model_name.human(count: 2) },
                         { link: users_document_path(@document), text: I18n.t('views.breadcrumbs.show',
                                                                              model: Document.model_name.human,
                                                                              id: @document.id) },
                         { link: users_document_recipients_path, text: I18n.t('views.document.recipients.plural') })
    end

    context 'add recipient' do
      should 'add' do
        assert_difference('DocumentRecipient.all.count', 1) do
          post users_document_add_recipient_path(@document.id, @user.cpf)
        end

        assert_redirected_to users_document_recipients_path
        assert_equal I18n.t('flash.actions.add.m', resource_name: I18n.t('views.document.recipients.name')),
                     flash[:success]
      end

      should 'unsuccessfully' do
        post users_document_add_recipient_path(@document.id, @user.cpf)
        post users_document_add_recipient_path(@document.id, @user.cpf)

        assert_equal I18n.t('flash.actions.add.errors.not'),
                     flash[:error]

        assert_equal 1, @document.recipients.all.count
      end
    end

    context 'remove recipient' do
      should 'remove' do
        create(:document_recipient, document: @document, cpf: @user.cpf,
                                    profile_id: @user.id, profile_type: @user.class.name)

        assert_difference('DocumentRecipient.count', -1) do
          delete users_document_remove_recipient_path(@document.id, @user.cpf)
        end

        assert_redirected_to users_document_recipients_path
        assert_equal I18n.t('flash.actions.destroy.m',
                            resource_name: I18n.t('views.document.recipients.name')), flash[:success]
      end

      should 'unsuccessfully' do
        create(:document_recipient, document: @document, cpf: @user.cpf,
                                    profile_id: @user.id, profile_type: @user.class.name)

        delete users_document_remove_recipient_path(@document.id, @non_existent_cpf)

        assert_equal 1, @document.recipients.all.count
      end
    end

    context 'add or remove recipient when document is signed' do
      setup do
        @document_signer.sign
        @flash = I18n.t('flash.actions.add_recipients.non')
      end

      should 'not redirect to users_documents_path when try access list page' do
        get users_document_recipients_path(@document)

        assert_response 200
      end

      should 'redirect to users_documents_path when try access new page' do
        get users_new_recipient_document_path(@document)

        assert_response 302
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.add_recipients.non'), flash[:warning]
      end

      should 'redirect to users_documents_path when post data to add' do
        assert_no_difference('DocumentRecipient.count') do
          post users_document_add_recipient_path(@document.id, @user.cpf)
        end

        assert_response 302
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.add_recipients.non'), flash[:warning]
      end

      should 'redirect to users_documents_path when delete' do
        create(:document_recipient, document: @document, cpf: @user.cpf,
                                    profile_id: @user.id, profile_type: @user.class.name)

        assert_no_difference('DocumentRecipient.count') do
          delete users_document_remove_recipient_path(@document.id, @user.cpf)
        end

        assert_response 302
        assert_redirected_to users_documents_path
        assert_equal I18n.t('flash.actions.add_recipients.non'), flash[:warning]
      end
    end
  end
end
