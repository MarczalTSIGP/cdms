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

  context 'default variables' do
    setup do
      @document = Document.new
    end

    should 'return all' do
      dv = []
      dv <<  { name: User.human_attribute_name(:name),  identifier: :name  }
      dv <<  { name: User.human_attribute_name(:cpf),   identifier: :cpf   }
      dv <<  { name: User.human_attribute_name(:email), identifier: :email }
      dv <<  { name: User.human_attribute_name(:register_number), identifier: :register_number }

      assert_equal dv, @document.default_variables
    end
  end

  context 'variables' do
    setup do
      department = create(:department)
      @document = build(:document, :declaration, department: department)
    end

    should 'be an empty array by default' do
      assert @document.valid?
    end

    should 'only accept array of json' do
      @document.variables = { name: 'Nome', identifier: 'name' }

      assert_not @document.valid?
      assert_equal 1, @document.errors.messages[:variables].size
      assert_contains @document.errors.messages[:variables], I18n.t('activerecord.errors.messages.not_an', type: Array)

      @document.variables = [{ name: 'Nome', identifier: 'name' }]
      assert @document.valid?
    end

    should 'accept only with name and identifier keys' do
      @document.variables = [{ name: 'Nome', identiier: 'name' }]

      assert_not @document.valid?
      assert_contains @document.errors.messages[:variables], I18n.t('activerecord.errors.messages.invalid')
    end

    should 'accept json format' do
      json = [{ name: 'Nome', identifier: 'name' }]
      @document.variables = json

      assert_equal 'Nome', @document.variables[0]['name']
      assert_equal 'name', @document.variables[0]['identifier']
    end

    should 'accept json format in string' do
      json_s = '[{"name":"Nome","identifier":"name"}]'
      @document.variables = json_s

      assert_equal 'Nome', @document.variables[0]['name']
      assert_equal 'name', @document.variables[0]['identifier']
    end

    should 'not accept json string unformated' do
      json_s = '[{"name:"Nome","identifier":"name"}]'

      assert_raise JSON::ParserError do
        @document.variables = json_s
      end
    end
  end

  context 'users' do
    setup do
      department = create(:department)
      @document = build(:document, :declaration, department: department)
    end

    should 'be an empty array by default' do
      assert @document.valid?
    end

    should 'only accept array of json' do
      @document.users = { id: 1, name: 'name', cpf: '877.919.020-01' }

      assert_not @document.valid?
      assert_equal 1, @document.errors.messages[:users].size
      assert_contains @document.errors.messages[:users], I18n.t('activerecord.errors.messages.not_an', type: Array)

      @document.users = [{ id: 1, name: 'name', cpf: '877.919.020-01' }]
      assert @document.valid?
    end

    should 'accept only keys from schema' do
      @document.users = [{ name: 'Nome', identiier: 'name' }]

      assert_not @document.valid?
      assert_contains @document.errors.messages[:users], I18n.t('activerecord.errors.messages.invalid')
    end

    should 'accept json format in string' do
      json_s = '[{"id":"1","name":"Joseph", "cpf":"877.919.020-01"}]'
      @document.users = json_s

      assert_equal '1', @document.users[0]['id']
      assert_equal 'Joseph', @document.users[0]['name']
      assert_equal '877.919.020-01', @document.users[0]['cpf']
    end

    should 'not accept json string unformated' do
      json_s = '[{"name:"Nome","identifier":"name"}]'

      assert_raise JSON::ParserError do
        @document.users = json_s
      end
    end

    should 'be a uniqueness on json' do
      @document.users = [{ id: 1, name: 'name', cpf: '877.919.020-01' },
                         { id: 1, name: 'name', cpf: '877.919.020-01' },
                         { id: 2, name: 'name', cpf: '877.919.020-01' }]

      assert_not @document.valid?
      assert_contains @document.errors.messages[:users], I18n.t('activerecord.errors.messages.taken')
    end
  end
end
