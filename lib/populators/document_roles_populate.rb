require_relative 'base_populate'

class Populators::DocumentRolesPopulate < Populators::BasePopulate
  attr_accessor :document_roles

  def self.populate(amount = 0)
    instance.delete
    amount.zero? ? instance.create : amount.times { instance.create_with_faker }
    instance.log(amount.zero? ? DocumentRole.count : amount)
  end

  def initialize(*)
    super
    self.document_roles = [
      { name: 'Aluno', description: 'Acadêmico da Instituição' },
      { name: 'Professor', description: 'Professor da Disciplina' },
      { name: 'Coordenador', description: 'Coordenador do Curso' }
    ]
  end

  def create
    document_roles.each do |document_role|
      DocumentRole.create!(
        name: document_role[:name],
        description: document_role[:description]
      )
    end
  end

  #   USED TO CREATE FAKER DOCUMENT ROLES
  def create_with_faker
    DocumentRole.create!(
      name: Faker::Job.position,
      description: Faker::Job.title
    )
  end
end
