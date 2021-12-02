module BreadcrumbsMembers
  extend ActiveSupport::Concern

  def breadcrumbs_members(model)
    add_breadcrumb I18n.t('views.breadcrumbs.show', model: model.class.model_name.human, id: model.id),
                   users_document_path(model)
    add_breadcrumb I18n.t('views.document.members.name'), users_document_members_path(model)
  end
end
