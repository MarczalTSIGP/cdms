require 'test_helper'

class DepartmentModuleTest < ActiveSupport::TestCase
  subject { FactoryBot.build(:department_module) }

  context 'relationships' do
    should have_one(:department_module_responsible).conditions(role: :responsible).class_name('DepartmentModuleUser')
    should have_one(:responsible).through(:department_module_responsible).source(:user)
  end

  context 'validations' do
    should validate_presence_of(:name)
    should validate_presence_of(:description)

    should validate_uniqueness_of(:name)
  end

  context 'members' do
    setup do
      @dmodule = create(:department_module)
    end

    should '#search_non_members' do
      user1 = create(:user, name: 'usuario 1')
      user2 = create(:user, name: 'usuario 2')

      create(:department_module_user, :collaborator,
             department_module: @dmodule, user: user1)

      response = @dmodule.search_non_members('u')

      assert_equal([user2], response)
    end

    should '#search_non_members_with_accent' do
      user_joao = create(:user, name: 'João')
      user_joao_with_accent = create(:user, name: 'Joao')

      response = @dmodule.search_non_members('joao')

      assert_contains(response, user_joao)
      assert_contains(response, user_joao_with_accent)
    end

    should '#search_non_members_order_ascii' do
      user1 = create(:user, name: 'Aab')
      user2 = create(:user, name: 'Abc')
      user3 = create(:user, name: 'Baa')

      response = @dmodule.search_non_members('a')

      assert_equal(user1, response[0])
      assert_equal(user2, response[1])
      assert_equal(user3, response[2])
    end

    should 'add member' do
      user_a = create(:user, name: 'user_a')

      @dmodule.add_member({ role: :collaborator, user: user_a })

      assert_equal 1, @dmodule.members.count
    end

    should 'not add member' do
      user_a = create(:user, name: 'user_a')

      @dmodule.add_member({ user: user_a })

      assert_equal 0, @dmodule.members.count
    end

    should 'not add two responsibles' do
      user_a = create(:user, name: 'user_a')
      user_b = create(:user, name: 'user_b')

      @dmodule.add_member({ role: :responsible, user: user_a })
      @dmodule.add_member({ role: :responsible, user: user_b })

      assert_equal 1, @dmodule.members.count
    end

    should 'remove member' do
      user_a = create(:user, name: 'user_a')
      create(:department_module_user, :collaborator, user: user_a, department_module: @dmodule)
      @dmodule.remove_member(user_a.id)

      assert_equal 0, @dmodule.members.count
    end
  end
end
