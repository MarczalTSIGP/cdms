require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:name)
    should validate_presence_of(:register_number)

    context 'relationships' do
      should have_many(:documents_created).class_name(:Document)
                                          .with_foreign_key(:creator_user_id)
                                          .dependent(:destroy)
                                          .inverse_of(:creator_user)
    end

    context '#username' do
      subject { FactoryBot.build(:user) }

      setup do
        @user = build(:user)
      end

      should validate_uniqueness_of(:username)

      should 'valid format' do
        usernames = %w[username user123]

        usernames.each do |username|
          @user.username = username
          assert @user.valid?, "'#{username}' should be valid"
        end
      end

      should 'invalid format' do
        usernames = ['user name', 'useá123', 'user$name']

        usernames.each do |username|
          @user.username = username
          assert_not @user.valid?, "'#{username}' should be invalid"
        end
      end
    end

    context '#cpf' do
      setup do
        @user = build(:user)
      end

      should 'valid format' do
        cpfs = ['521.399.891-71', '573.574.880-71']

        cpfs.each do |cpf|
          @user.cpf = cpf
          assert @user.valid?, "'#{cpf}' should be valid"
        end
      end

      should 'invalid format' do
        cpfs = ['01234567890', '11111111111', 'aaa.bbb.ccc-dd']

        cpfs.each do |cpf|
          @user.cpf = cpf
          assert_not @user.valid?, "'#{cpf}' should be invalid"
        end
      end
    end
  end

  context '#username to email' do
    setup do
      @user = build(:user)
    end

    should 'build email' do
      @user.username = 'guest'
      assert_equal('guest@utfpr.edu.br', @user.email)
    end
  end

  context 'admin' do
    should belong_to(:role).optional

    context 'role' do
      setup do
        @user = create(:user)
      end

      should 'not be admin' do
        assert_not @user.is?(:admin)
        assert_not @user.is?(:assistant)
        assert_not @user.is?(:manager)
      end

      should 'be manager' do
        create(:role_manager)
        @user.role = Role.find_by(identifier: :manager)

        assert @user.is?(:admin)
        assert @user.is?(:manager)
      end

      should 'be assistant' do
        create(:role_assistant)
        @user.role = Role.find_by(identifier: :assistant)

        assert @user.is?(:admin)
        assert @user.is?(:assistant)
      end

      should '#last_manager' do
        user = create(:user, :manager)
        assert user.last_manager?

        create(:user, :manager)
        assert_not user.last_manager?
      end

      should 'not destroy if the last manager' do
        user = create(:user, :manager)
        assert_not user.destroy
        message = I18n.t('flash.actions.least', resource_name: Administrator.model_name.human)
        assert_includes user.errors[:base], message
      end
    end

    should '.admins' do
      create_list(:user, 2)
      create_list(:user, 2, :manager)
      create_list(:user, 2, :assistant)

      assert_equal 4, User.admins.count
    end

    should '.search_non_admins' do
      users = create_list(:user, 2, name: 'User')
      create_list(:user, 2, :manager)
      create_list(:user, 2, :assistant)

      assert_equal User.search_non_admins('u'), users
    end
  end

  context 'search' do
    should 'by name case insensitive' do
      first_name = 'Eduardo'
      second_name = 'Pedro'

      FactoryBot.create(:user, name: first_name)
      FactoryBot.create(:user, name: second_name)

      assert_equal(1, User.search(first_name).count)
      assert_equal(1, User.search(second_name).count)
      assert_equal(1, User.search(first_name.downcase).count)
      assert_equal(1, User.search(second_name.downcase).count)
      assert_equal(2, User.search('').count)
    end
  end

  context 'departments and modules' do
    should 'by user' do
      user = create(:user)
      create(:department_user, :responsible, user: user)

      department = create(:department)
      create(:department_user, :responsible, user: user, department: department)

      dep_module = create(:department_module, department: department)
      create(:department_module_user, :collaborator, user: user, department_module: dep_module)

      assert_equal(2, user.departments_and_modules.count)
      assert_equal(department, user.departments_and_modules[1][:department])
      assert_equal(dep_module, user.departments_and_modules[1][:modules][0][:module])
    end
  end

  context '.department' do
    should '.responsible_of?' do
      user = create(:user)
      assert_not user.responsible_of?(nil)

      department = create(:department)

      assert_not user.responsible_of?(department)

      department.department_users.create(user: user, role: :responsible)
      assert user.responsible_of?(department)
    end

    should '.is_member_of_any?' do
      user = create(:user)
      assert_not user.member_of_any?

      department = create(:department)
      department.department_users.create(user: user, role: :responsible)
      assert user.member_of_any?
    end

    should 'list all documentos of member department' do
      user = create(:user)
      department = create(:department)
      department.department_users.create(user: user, role: :collaborator)
      documents = create_list(:document, 3, :certification, department: department)

      # same department user
      department.department_users.create(user: create(:user), role: :collaborator)
      documents << create(:document, :declaration, department: department)

      # other department user
      department = create(:department)
      department.department_users.create(user: create(:user), role: :responsible)
      create_list(:document, 3, :declaration, department: department)

      assert_same_elements documents, user.documents
    end
  end

  context 'documents to sign' do
    setup do
      @user = create(:user)
      document_signers = create_list(:document_signer, 4, user: @user)
      @documents = document_signers.map(&:document)
      @documents.each { |document| document.update(available_to_sign: true) }
    end

    should 'return all documents available to signer' do
      assert 4, @user.unsigned_documents.size
      assert_same_elements @documents, @user.unsigned_documents
    end

    should 'not return documents not available to signer' do
      documents = @documents.pop(2)
      documents.each { |document| document.update(available_to_sign: false) }

      assert 2, @user.unsigned_documents.size
      assert_same_elements @documents, @user.unsigned_documents
    end

    should 'not return documents signed' do
      create_list(:document_signer, 2, user: @user, signed: true)

      assert 4, @user.unsigned_documents.size
      assert_same_elements @documents, @user.unsigned_documents
    end

    should 'not return documents from other users' do
      other_user = create(:user)
      create_list(:document_signer, 2, user: other_user)

      assert 4, @user.unsigned_documents.size
      assert_same_elements @documents, @user.unsigned_documents
    end
  end
end
