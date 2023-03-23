require 'test_helper'

class PageTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:content)
    should validate_presence_of(:url)
    should validate_uniqueness_of(:url)

    context '#content' do
      setup do
        @page = Page.new
      end

      should 'invalid content' do
        assert_not @page.valid?
        assert_includes @page.errors.messages[:content], I18n.t('errors.messages.blank')
      end

      should 'valid content' do
        @page.url = 'url'
        @page.content = 'content'

        assert_predicate @page, :valid?
      end
    end
  end
end
