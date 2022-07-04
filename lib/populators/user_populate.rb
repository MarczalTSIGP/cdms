require_relative 'base_populate'

class Populators::UserPopulate < Populators::BasePopulate
  def create
    User.create!(
      name: Faker::Name.unique.name,
      username: Faker::Internet.unique.username,
      register_number: Faker::Number.number(digits: 7),
      cpf: CPF.generate(true),
      password: '123456',
      active: active_sample
    )
  end

  def active_sample
    [true, false].sample
  end
end
