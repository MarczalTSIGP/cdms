class DepartmentModule < ApplicationRecord
  include Members
  build_member_methods(relationship: :users, name: :member)

  belongs_to :department

  has_many :department_module_users, dependent: :destroy
  has_many :users, through: :department_module_users

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
