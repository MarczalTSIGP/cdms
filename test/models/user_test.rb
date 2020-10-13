require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:name)
    should validate_presence_of(:register_number)

    context '#username' do
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

  context 'queries' do
    should 'search' do
      first_name = 'Eduardo'
      second_name = 'Pedro'

      FactoryBot.create(:user, name: first_name)
      FactoryBot.create(:user, name: second_name)

      assert_equal(1, User.search(['name'], first_name).count)
      assert_equal(1, User.search(['name'], second_name).count)
      assert_equal(2, User.search(['name'], '').count)
    end
  end
end
