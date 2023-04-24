module Users
  module Breadcrumbs
    module DocumentRecipients
      def self.included(base)
        base.class_eval do
          before_action :set_breadcrumb_documents, only: [:index, :new]
          before_action :set_breadcrumb_document, only: [:index, :new, :from]
          before_action :set_breadcrumb_index, only: [:index]
          before_action :set_breadcrumb_new, only: [:new]
          before_action :set_breadcrumb_document_recipients, only: [:from_csv, :create_from_csv]
        end
      end

      private

      def set_breadcrumb_documents
        add_breadcrumb Document.model_name.human(count: 2), :users_documents_path
      end

      def set_breadcrumb_document
        add_breadcrumb I18n.t('views.breadcrumbs.show', model: Document.model_name.human, id: @document.id),
                       users_document_path(@document)
      end

      def set_breadcrumb_index
        add_breadcrumb I18n.t('views.document.recipients.plural')
      end

      def set_breadcrumb_new
        add_breadcrumb I18n.t('views.document.recipients.plural'), :users_document_recipients_path
        add_breadcrumb I18n.t('views.document.recipients.new')
      end

      def set_breadcrumb_document_recipients
        add_breadcrumb t('activerecord.models.document.other'), users_documents_path
        add_breadcrumb t('activerecord.models.document.one') + " ##{params[:id]}", users_document_path(params[:id])
        add_breadcrumb t('views.document.recipients.plural'), users_document_recipients_path
        add_breadcrumb t('views.document.recipients.import.btn_csv'), users_new_document_recipients_from_csv_path
      end
    end
  end
end
