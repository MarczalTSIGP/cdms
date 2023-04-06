require_relative 'base_populate'

class Populators::DocumentRolesPopulate < Populators::BasePopulate
  attr_accessor :document_roles

  def self.populate(amount)
    instance.delete
    amount.times { instance.create }
    instance.log(DocumentRole.count)
  end

  def create
    DocumentRole.create!(
      name: Faker::Job.unique.position,
      description: Faker::Job.title
    )
  end
end
