module Users
  module Breadcrumbs
    module DocumentSigners
      def self.included(base)
        base.class_eval do
          before_action :set_signers_breadcrumbs, only: [:signers, :add_signer]
        end
      end

      private

      def set_signers_breadcrumbs
        add_breadcrumb I18n.t('views.document.signers.nwdc',
                              name: "#{@document.model_name.human}\##{@document.id}"),
                       users_document_signers_path(@document)
      end
    end
  end
end
