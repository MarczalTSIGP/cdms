module Admins
  module Breadcrumbs
    module DepartmentModules
      def self.included(base)
        base.class_eval do
          before_action :set_breadcrumbs
          before_action :set_update_breadcrumbs, only: [:edit, :update]
          before_action :set_create_breadcrumbs, only: [:new, :create]
          before_action :set_members_breadcrumbs, only: :members
          before_action :set_add_module_member_breadcrumbs, only: :add_module_member
        end
      end

      private

      def set_breadcrumbs
        model_name = @department.model_name
        add_breadcrumb model_name.human(count: 2), admins_departments_path
        add_breadcrumb I18n.t('views.breadcrumbs.show', model: model_name.human, id: @department.id),
                       admins_department_path(@department)
      end

      def set_update_breadcrumbs
        add_breadcrumb I18n.t('views.breadcrumbs.show', model: @module.model_name.human, id: @module.id),
                       admins_department_path(@department.id)
        add_breadcrumb I18n.t('views.breadcrumbs.edit'), edit_admins_department_module_path
      end

      def set_create_breadcrumbs
        add_breadcrumb I18n.t('views.breadcrumbs.new.m'), new_admins_department_module_path
      end

      def set_members_breadcrumbs
        add_breadcrumb I18n.t('views.breadcrumbs.show',
                              model: @module.model_name.human, id: @module.id),
                       admins_department_module_members_path(@department, @module)
      end

      def set_add_module_member_breadcrumbs
        add_breadcrumb I18n.t('views.breadcrumbs.show',
                              model: @module.model_name.human, id: @module.id),
                       admins_department_module_members_path(@department, @module)
      end
    end
  end
end
