require 'test_helper'

class DepartmentUserTest < ActiveSupport::TestCase
  subject { FactoryBot.build(:department_user, :collaborator) }

  context 'validations' do
    should validate_uniqueness_of(:user).scoped_to([:department_id]).ignoring_case_sensitivity

    should 'inclusion of role' do
      du = DepartmentUser.new

      assert_not du.valid?
      assert_includes du.errors.messages[:role], I18n.t('errors.messages.inclusion')
    end

    should 'have only one responsible' do
      du = create(:department_user, :responsible)
      department = du.department
      dudr = department.department_users.new(user: create(:user), role: du.role)

      assert_not dudr.valid?
      assert_includes dudr.errors.messages[:role], I18n.t('errors.messages.taken')
    end

    should 'not accept duplicate user' do
      du = create(:department_user, :responsible)
      department = du.department
      dudr = department.department_users.new(user: du.user)

      assert_not dudr.valid?
      assert_includes dudr.errors.messages[:user], I18n.t('errors.messages.taken')
    end
  end

  context 'role' do
    should define_enum_for(:role)
      .with_values(responsible: 'responsible', collaborator: 'collaborator')
      .backed_by_column_of_type(:enum)
      .with_suffix(:role)

    should 'human enum' do
      hash = { I18n.t('enums.roles.responsible') => 'responsible',
               I18n.t('enums.roles.collaborator') => 'collaborator' }

      assert_equal hash, DepartmentUser.human_roles
    end
  end
end
