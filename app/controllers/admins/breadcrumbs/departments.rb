module Admins
  module Breadcrumbs
    module Departments
      def self.included(base)
        base.class_eval do
          before_action :set_members_breadcrumbs, only: [:members, :add_member]
        end
      end

      private

      def set_members_breadcrumbs
        add_breadcrumb I18n.t('views.department.members.nwdp',
                              name: "##{@department.id}"),
                       admins_department_members_path(@department)
      end
    end
  end
end
