class AdminDashboard
  # departments.count
  # departments.human
  def self.departments
    OpenStruct.new count: Department.count, human: Department.model_name.human(count: Department.count)
  end
end
