require 'test_helper'

class AdministratorTest < ActiveSupport::TestCase
  context 'validations' do
    should validate_presence_of(:user)
    should validate_presence_of(:role_id)
  end

  should '#save' do
    user = FactoryBot.create(:user)
    role = FactoryBot.create(:role_manager)

    administrator = Administrator.new(user: user.name,
                                      user_id: user.id,
                                      role_id: role.id)

    assert administrator.save
    user.reload

    assert user.is?(:admin)
    assert user.is?(:manager)
  end
end
