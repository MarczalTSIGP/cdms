module Users::DashboardHelper
  def documents_to_sign_partial(documents)
    return 'users/dashboard/documents/to_sign' unless documents.empty?

    'users/dashboard/documents/non_documents_to_sign'
  end
end
