module ApplicationHelper
  def bootstrap_class_for(flash_type)
    { success: 'alert-success', error: 'alert-danger', alert: 'alert-warning',
      notice: 'alert-info', edit: 'alert-info' }[flash_type.to_sym] || "alert-#{flash_type}"
  end

  def full_title(page_title = '', base_title = t('views.app.title'))
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
end
