require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  subject { FactoryBot.build(:department) }

  context 'relationships' do
    should have_one(:department_responsible).conditions(role: :responsible).class_name('DepartmentUser')
    should have_one(:responsible).through(:department_responsible).source(:user)
  end

  context 'validations' do
    should validate_presence_of(:name)
    should validate_presence_of(:initials)
    should validate_presence_of(:local)

    should validate_uniqueness_of(:initials)
    should validate_uniqueness_of(:email).ignoring_case_sensitivity

    context 'email format' do
      should 'valid' do
        valid_emails = ['teste@utfpr.edu.br', 'teste@gmail.com']
        valid_emails.each do |valid_email|
          subject.email = valid_email

          assert_predicate subject, :valid?
        end
      end

      should 'invalid' do
        valid_emails = ['teste@', 'teste@gmail']
        valid_emails.each do |valid_email|
          subject.email = valid_email

          assert_predicate subject, :invalid?
        end
      end
    end

    context 'phone format' do
      should 'valid' do
        valid_phones = ['(42) 99903-4056', '(42) 9903-4213']
        valid_phones.each do |valid_phone|
          subject.phone = valid_phone

          assert_predicate subject, :valid?, "#{valid_phone} is invalid"
        end
      end

      should 'invalid' do
        valid_phones = %w[123123asdsa asdasdasds]
        valid_phones.each do |valid_phone|
          subject.phone = valid_phone

          assert_predicate subject, :invalid?
        end
      end
    end
  end

  context 'members' do
    should 'search non members' do
      department = create(:department)
      user_a = create(:user, name: 'user_a')
      user_b = create(:user, name: 'user_b')
      create(:department_user, :collaborator, user: user_a, department: department)

      assert_not_equal [user_a], department.search_non_members('a')
      assert_equal [user_b], department.search_non_members('b')
    end

    should 'add member' do
      department = create(:department)
      user_a = create(:user, name: 'user_a')

      department.add_member({ role: :collaborator, user: user_a })

      assert_equal 1, department.members.count
    end

    should 'not add member' do
      department = create(:department)
      user_a = create(:user, name: 'user_a')

      department.add_member({ user: user_a })

      assert_equal 0, department.members.count
    end

    should 'not add two responsibles' do
      department = create(:department)
      user_a = create(:user, name: 'user_a')
      user_b = create(:user, name: 'user_b')

      department.add_member({ role: :responsible, user: user_a })
      department.add_member({ role: :responsible, user: user_b })

      assert_equal 1, department.members.count
    end

    should 'remove member' do
      department = create(:department)
      user_a = create(:user, name: 'user_a')
      create(:department_user, :collaborator, user: user_a, department: department)
      department.remove_member(user_a.id)

      assert_equal 0, department.members.count
    end
  end

  context 'search' do
    should 'by name case insensitive' do
      first_name = 'Tecnologia em Sistemas Para Internet'
      second_name = 'Tecnologia em Manutenção Industrial'

      FactoryBot.create(:department, name: first_name)
      FactoryBot.create(:department, name: second_name)

      assert_equal(1, Department.search(first_name).count)
      assert_equal(1, Department.search(second_name).count)
      assert_equal(1, Department.search(first_name.downcase).count)
      assert_equal(1, Department.search(second_name.downcase).count)
      assert_equal(2, Department.search('').count)
    end
    should 'by initials case sensitive' do
      first_initial = 'TSI'
      second_initial = 'TMI'

      FactoryBot.create(:department, initials: first_initial)
      FactoryBot.create(:department, initials: second_initial)

      assert_equal(1, Department.search(first_initial).count)
      assert_equal(1, Department.search(second_initial).count)
      assert_equal(0, Department.search(first_initial.downcase).count)
      assert_equal(0, Department.search(second_initial.downcase).count)
      assert_equal(2, Department.search('').count)
    end
  end

  context 'verify user role' do
    should 'return false' do
      department_user = create(:department_user, :responsible)

      assert_not department_user.department.user_is_collaborator?(department_user.user)
    end

    should 'return true' do
      department_user = create(:department_user, :collaborator)

      assert department_user.department.user_is_collaborator?(department_user.user)
    end
  end
end
