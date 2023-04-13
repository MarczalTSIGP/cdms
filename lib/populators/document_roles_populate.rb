require_relative 'base_populate'

class Populators::DocumentRolesPopulate < Populators::BasePopulate
  attr_accessor :document_roles

  def create
    DocumentRole.create!(
      name: Faker::Job.unique.position,
      description: Faker::Job.title
    )
  end
end
