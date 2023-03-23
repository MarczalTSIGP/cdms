class DepartmentModule < ApplicationRecord
  include Members
  build_member_methods(relationship: :users, name: :member)

  belongs_to :department

  has_many :department_module_users, dependent: :destroy
  has_many :users, through: :department_module_users

  has_one :department_module_responsible, -> { where(role: :responsible) },
          class_name: 'DepartmentModuleUser', inverse_of: false, dependent: :restrict_with_error
  has_one :responsible, through: :department_module_responsible, source: :user, inverse_of: false

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
