class DocumentsController < ApplicationController
    def index
        if params[:document] && params[:document][:code]
            code = params[:document][:code]
            if code.present?
                redirect_to show_document_path(code)
            else
                flash[:warning] = "Digite um código válido!"
            end
        end
    end

    def show
        @document_recipient = DocumentRecipient.find_by(verification_code: params[:code])
        
        if @document_recipient
            @document = @document_recipient.document

            #melhorar com um modal sharede########################################################################################
            flash[:success] = "Documento valido!! #{params[:code]}"
        else
            flash[:warning] = "Não existe um documento com o código #{params[:code]}"
            redirect_to documents_path
        end
        #@document = Document.find_by(verification_code: params[:code])
    end
end
  