class AdminDashboard
  def self.departments
    OpenStruct.new count: Department.count, human: Department.model_name.human(count: Department.count)
  end

  def self.active_users
    users = User.where(active: true).count
    OpenStruct.new count: users, human: User.model_name.human(count: users)
  end

  def self.inactive_users
    users = User.where(active: false).count
    OpenStruct.new count: users, human: User.model_name.human(count: users)
  end

  def self.audience_members
    members = AudienceMember.count
    OpenStruct.new count: members, human: AudienceMember.model_name.human(count: members)
  end
end
