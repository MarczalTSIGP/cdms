require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:title)
    should validate_presence_of(:front_text)
    should validate_presence_of(:back_text)

    should 'inclusion of category' do
      document = Document.new
      assert_not document.valid?
      assert_includes document.errors.messages[:category], I18n.t('errors.messages.inclusion')
    end
  end
  context 'category' do
    should define_enum_for(:category)
      .with_values(declaration: 'declaration', certification: 'certification')
      .backed_by_column_of_type(:enum)
      .with_suffix(:category)

    should 'human enum' do
      hash = { I18n.t('enums.categories.declaration') => 'declaration',
               I18n.t('enums.categories.certification') => 'certification' }

      assert_equal hash, Document.human_categories
    end
  end

  context 'variables' do
    should 'be array' do
      department = create(:department)
      document = build(:document, :declaration, department: department)
      assert document.valid?
      document.variables = []
      assert document.valid?
    end
   
    should 'not accept duplicate variables' do
      json = [{ name: 'Nome', identifier: 'name' }]
      department = create(:department)
      dv = build(:document, :declaration, department: department)
      dv.variables = json
      dv2 = build(:document, :declaration, department: department)
      dv2.variables = json
      assert_not dv2.valid?
      assert_includes dv2.errors.messages[:identifier], I18n.t('errors.messages.taken')
    end
    
    should 'remove variables' do
      json = [{ name: 'Nome', identifier: 'Identifier' }]
      document = build(:document)
      document.variables = json
      document.variables.delete_at(0)
      assert_equal 0, document.variables.count
    end

    should 'accept json format' do
      json = [{ name: 'Nome', identifier: 'name' }]

      document = build(:document)
      document.variables = json

      assert_equal 'Nome', document.variables[0]['name']
      assert_equal 'name', document.variables[0]['identifier']
    end

    should 'accept json format in string' do
      json_s = '[{"name":"Nome","identifier":"name"}]'

      document = build(:document)
      document.variables = json_s

      assert_equal 'Nome', document.variables[0]['name']
      assert_equal 'name', document.variables[0]['identifier']
    end

    should 'not accept json string unformated' do
      json_s = '[{"name:"Nome","identifier":"name"}]'
      document = build(:document)

      assert_raise JSON::ParserError do
        document.variables = json_s
      end
    end
  end
end
