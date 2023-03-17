require_relative 'base_populate'

class Populators::DocumentRolesPopulate < Populators::BasePopulate
  
    def self.populate(_amount = 0)
        instance.delete
        _amount > 0 ? _amount.times { self.create_with_faker } : self.create
        instance.log(_amount > 0 ? _amount : DocumentRole.count)
    end
    
    def self.create
        document_roles = [
            {name: 'Aluno', description: 'Acadêmico da Instituição'}, 
            {name: 'Professor', description: 'Professor da Instituição'}, 
            {name: 'Coordenador', description: 'Coordenador do Curso'}, 
            {name: 'Diretor', description: 'Diretor de Câmpus'}, 
            {name: 'Secretário', description: 'Secretário Geral'}
        ]

        document_roles.each do |document_role|
            DocumentRole.create!(
            name: document_role[:name],
            description: document_role[:description],
        )
        end
    end
  
#   USED TO CREATE FAKER DOCUMENT ROLES
    def self.create_with_faker
    DocumentRole.create!(
      name: Faker::Job.position,
      description: Faker::Job.title,
    )
    end

end
