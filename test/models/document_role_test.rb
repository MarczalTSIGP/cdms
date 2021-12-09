require 'test_helper'

class DocumentRoleTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:name)
    should validate_uniqueness_of(:name)
  end
end
