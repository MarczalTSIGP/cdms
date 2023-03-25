Dir[Rails.root.join('lib/populators/*.rb')].each { |file| require file }

namespace :db do
  desc 'Erase and fill database'
  task populate: :environment do
    include Populators
    Rails.logger = Logger.new($stdout)

    puts 'Running seeds'
    Rake::Task['db:seed'].invoke

    DocumentRolesPopulate.populate(8)
    UserPopulate.populate(30)
    AudienceMemberPopulate.populate
    DepartmentPopulate.populate
    DepartmentModulePopulate.populate
    DepartmentUserPopulate.populate
    DepartmentModuleUserPopulate.populate
  end
end
