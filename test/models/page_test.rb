require 'test_helper'

class PageTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:content)

    context '#content' do
      setup do
        @page = Page.new
      end

      should 'invalid content' do
        assert_not @page.valid?
        assert_includes @page.errors.messages[:content], I18n.t('errors.messages.blank')
      end

      should 'valid content' do
        @page.content = 'content'
        assert @page.valid?
      end
    end
  end
end
