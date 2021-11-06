class AdminDashboard
  def self.departments
    OpenStruct.new count: Department.count, human: Department.model_name.human(count: Department.count)
  end

  def self.active_users
    users = User.where(active: true).count

    human = User.model_name.human(count: users)
    human += " #{User.human_attribute_name(:active, count: users)}"

    OpenStruct.new count: users, human: human
  end

  def self.inactive_users
    users = User.where(active: false).count

    human = User.model_name.human(count: users)
    human += " #{User.human_attribute_name(:inactive, count: users)}"

    OpenStruct.new count: users, human: human
  end

  def self.audience_members
    members = AudienceMember.count
    OpenStruct.new count: members, human: AudienceMember.model_name.human(count: members)
  end

  def self.counters
    [
      departments,    active_users,
      inactive_users, audience_members
    ]
  end
end
