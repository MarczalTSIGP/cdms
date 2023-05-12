require 'application_system_test_case'

class PreviewDocumentTest < ApplicationSystemTestCase
  context 'Preview' do
    setup do
      user = create(:user, :manager)
      login_as(user, scope: :user)

      @department = create(:department)
      @department.department_users.create(user: user, role: :responsible)
      @document = create(:document, :certification, department: @department)
    end

    context 'Content' do
      should 'successfully display' do
        visit users_preview_document_path(@document)

        assert_selector('ol.breadcrumb li:last-child', text: I18n.t('views.document.preview', id: @document.id))
        title = "#{@document.id}/#{@document.created_at.year} - #{@document.department.name}"

        assert_selector('#document .document-title', text: title)
        assert_selector('#document .document-content', text: @document.content)
      end

      should 'successfully preview' do
        visit users_preview_document_path(@document)

        print_window = page.window_opened_by do
          click_link_or_button I18n.t('views.document.links.print')
        end
        print_window.close
      end
    end
  end
end
