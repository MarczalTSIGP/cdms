require 'test_helper'
class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @department = create(:department)
    @document = create(:document, :certification, department: @department)
    @non_existent_cpf = '01234567890'
    @document_signer = create(:document_signer, document_id: @document.id)
    sign_in @user
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

  #METODO NEW DE DOCUMENT-RECIPIENT CONTROLLER - usar para criar um recipient
  # def new
  #   return unless (cpf = params[:cpf])

  #   @document_recipient = DocumentRecipient.find_by(cpf: cpf, document_id: @document.id)

  #   if @document_recipient
  #     flash.now[:warning] = I18n.t('flash.actions.add.errors.exists',
  #                                  resource_name: I18n.t('views.document.recipients.name'))
  #   else
  #     @recipient = Logics::Document::Recipient.find_by(cpf: cpf)
  #     flash.now[:warning] = I18n.t('flash.not_found') unless @recipient
  #   end
  # end

  context 'public' do
    should 'get index' do
      #document_recipients = DocumentRecipient.where(document_id: @document.id)
      #puts @document.document_recipients.to_s
      # @document_recipient = DocumentRecipient.find_by(verification_code: params[:code])
      #@document_recipient = DocumentRecipient.find_by(document_id: @document.id)
      #puts @document_recipient.verification_code
      #puts @document.document_recipients.first.verification_code
      # verification_code = @document.recipients.first.verification_code
      # get documents_path(verification_code)
      # assert_response :success
      # post document_code_path, params: { document: { code: verification_code } }
      # assert_redirected_to document_path(@document)
    end
  end
end