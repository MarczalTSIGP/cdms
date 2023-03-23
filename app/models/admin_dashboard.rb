class AdminDashboard
  def self.departments
    model_name = Department.model_name
    model_count = Department.count

    key = "#{model_name.human}-#{model_count}"
    cache_struct.new amount: model_count, human: model_name.human(count: model_count), cache_key: key
  end

  def self.active_users
    users = User.where(active: true).count

    human = User.model_name.human(count: users)
    human += " #{User.human_attribute_name(:active, count: users)}"
    cache_struct.new amount: users, human: human, cache_key: "#{human}-#{User.count}"
  end

  def self.inactive_users
    users = User.where(active: false).count

    human = User.model_name.human(count: users)
    human += " #{User.human_attribute_name(:inactive, count: users)}"
    cache_struct.new amount: users, human: human, cache_key: "#{human}-#{User.count}"
  end

  def self.audience_members
    members = AudienceMember.count

    key = "#{AudienceMember.model_name.human}-#{members}"
    cache_struct.new amount: members, human: AudienceMember.model_name.human(count: members), cache_key: key
  end

  def self.counters
    [
      departments,    active_users,
      inactive_users, audience_members
    ]
  end

  def self.cache_struct
    Struct.new(:amount, :human, :cache_key)
  end
end
