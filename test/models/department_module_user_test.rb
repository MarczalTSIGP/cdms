require 'test_helper'

class DepartmentModuleUserTest < ActiveSupport::TestCase
  subject { FactoryBot.build(:department_module_user, :collaborator) }

  context 'validations' do
    should validate_uniqueness_of(:user).scoped_to([:department_module_id]).ignoring_case_sensitivity

    should 'inclusion of role' do
      du = DepartmentModuleUser.new

      assert_not du.valid?
      assert_includes du.errors.messages[:role], I18n.t('errors.messages.inclusion')
    end

    should 'have only one responsible' do
      dmu = create(:department_module_user, :responsible)
      department_module = dmu.department_module
      dmudp = department_module.department_module_users.new(user: create(:user), role: dmu.role)

      assert_not dmudp.valid?
      assert_includes dmudp.errors.messages[:role], I18n.t('errors.messages.taken')
    end

    should 'not accept duplicate user' do
      du = create(:department_module_user, :responsible)
      department_module = du.department_module
      dudr = department_module.department_module_users.new(user: du.user)

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

      assert_equal hash, DepartmentModuleUser.human_roles
    end
  end
end
