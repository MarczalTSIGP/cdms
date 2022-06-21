module BreadcrumbsMembers
  extend ActiveSupport::Concern

  def breadcrumbs_members(model)
    add_breadcrumb I18n.t('views.breadcrumbs.show', model: model.class.model_name.human, id: model.id), show_path(model)
    model_name = model.class.model_name.name.to_s.underscore.downcase
    target_type = model_name == 'document' ? 'signers' : 'members'
    add_breadcrumb I18n.t("views.#{model_name}.#{target_type}.name"), members_path(model)
  end

  private

  def show_path(model)
    namespace = self.class.module_parent.to_s.underscore.downcase
    model_name = model.class.model_name.name.to_s.underscore.downcase

    send("#{namespace}_#{model_name}_path", model)
  end

  def members_path(model)
    namespace = self.class.module_parent.to_s.underscore.downcase
    model_name = model.class.model_name.name.to_s.underscore.downcase
    target_type = model_name == 'document' ? 'signers' : 'members'

    send("#{namespace}_#{model_name}_#{target_type}_path", model)
  end
end
