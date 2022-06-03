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
      @document_role = create(:document_role)
    end

    should 'be an empty array by default' do
      assert @document.valid?
    end

    should 'only accept array of json' do
      @document.variables = { name: 'Nome', identifier: 'name' }

      assert_not @document.valid?
      assert_equal 1, @document.errors.messages[:variables].size
      assert_contains @document.errors.messages[:variables], I18n.t('activerecord.errors.messages.not_an_array')

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

    context 'members' do
      should 'search non members' do
        department = create(:department)

        @document = create(:document, :declaration, department: department)
        user_a = create(:user, name: 'user_a')
        user_b = create(:user, name: 'user_b')
        create(:document_user, user: user_a, document: @document, document_role: @document_role)

        assert_not_equal [user_a], @document.search_non_members('a')
        assert_equal [user_b], @document.search_non_members('b')
      end

      should 'add member' do
        department = create(:department)
        @document = create(:document, :declaration, department: department)
        user_a = create(:user, name: 'user_a')
        create(:document_user, user: user_a, document: @document, document_role: @document_role)
        @document.add_member({ user: user_a })

        assert_equal 1, @document.members.count
      end

      should 'remove member' do
        department = create(:department)
        @document = create(:document, :declaration, department: department)
        user_a = create(:user, name: 'user_a')
        create(:document_user, user: user_a, document: @document, document_role: @document_role)
        @document.remove_member(user_a.id)
        assert_equal 0, @document.members.count
      end
    end
  end

  context 'search' do
    should 'by title case insensitive' do
      first_title = 'Certificado Um'
      second_title = 'Certificado Dois'

      FactoryBot.create(:document, :certification, title: first_title)
      FactoryBot.create(:document, :certification, title: second_title)

      assert_equal(1, Document.search(first_title).count)
      assert_equal(1, Document.search(second_title).count)
      assert_equal(1, Document.search(first_title.downcase).count)
      assert_equal(1, Document.search(second_title.downcase).count)
      assert_equal(2, Document.search('').count)
    end
  end

  context 'recipients' do
    setup do
      department = create(:department)
      other_department = create(:department)
      @document = create(:document, :certification, department: department)
      @other_document = create(:document, :declaration, department: other_department)
      @user = create(:user)
      @audience_member = create(:audience_member)
      @non_existent_cpf = '01234567890'
    end

    should 'return recipients' do
      assert_equal 0, @document.recipients.count

      @document.add_recipient(@user.cpf)
      @document.add_recipient(@audience_member.cpf)

      recipients = @document.recipients
      assert_equal 2, recipients.count

      assert_equal @user.name, recipients[0].profile.name
      assert_equal @audience_member.name, recipients[1].profile.name
    end

    should 'do not return recipients of another document' do
      @document.add_recipient(@user.cpf)
      @other_document.add_recipient(@audience_member.cpf)

      recipients_document = @document.recipients

      assert_equal 1, recipients_document.count
      assert_equal @user.cpf, recipients_document[0].profile.cpf
    end

    should 'search non recipient' do
      profile = @document.search_non_recipient(@user.cpf)
      assert_equal profile.cpf, @user.cpf

      @document.add_recipient(profile.cpf)
      assert_not @document.search_non_recipient(@user.cpf)

      profile = @document.search_non_recipient(@audience_member.cpf)
      assert_equal profile.cpf, @audience_member.cpf

      @document.add_recipient(profile.cpf)
      assert_not @document.search_non_recipient(@audience_member.cpf)
    end

    should 'invalid parameters for non recipient search' do
      assert_nil @document.search_non_recipient('')
      assert_nil @document.search_non_recipient(@non_existent_cpf)
    end

    should 'add recipient' do
      @document.add_recipient(@user.cpf)
      @document.add_recipient(@audience_member.cpf)

      assert_equal 2, @document.recipients.count

      assert_not @document.add_recipient(@user.cpf)
      assert_not @document.add_recipient(@audience_member.cpf)

      recipients = @document.recipients

      assert_equal 2, recipients.count
      assert_equal @user.name, recipients[0].profile.name
      assert_equal @audience_member.name, recipients[1].profile.name
    end

    should 'invalid parameters to add recipient' do
      assert_not @document.add_recipient('')
      assert_not @document.add_recipient(@non_existent_cpf)

      assert_equal 0, @document.recipients.count
    end

    should 'remove recipient' do
      @document.add_recipient(@user.cpf)
      @document.add_recipient(@audience_member.cpf)

      assert_equal 2, @document.recipients.count

      @document.remove_recipient(@user.cpf)
      assert_equal 1, @document.recipients.count

      recipients = @document.recipients
      assert_equal @audience_member.name, recipients[0].profile.name
    end

    should 'invalid parameters to remove recipient' do
      @document.add_recipient(@user.cpf)

      assert_not @document.remove_recipient('')
      assert_not @document.remove_recipient(@non_existent_cpf)

      assert_equal 1, @document.recipients.count
    end
  end
end
