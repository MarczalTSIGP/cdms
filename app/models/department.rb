class Department < ApplicationRecord
  include Searchable
  search_by :name, initials: { case_sensitive: true }

  include Members
  build_member_methods(relationship: :users, name: :member)

  has_many :department_modules, dependent: :destroy
  has_many :department_users, dependent: :destroy
  has_many :users, through: :department_users
  has_many :documents, dependent: :destroy

  has_one :department_responsible, -> { where(role: :responsible) },
          class_name: 'DepartmentUser', inverse_of: false, dependent: :restrict_with_error
  has_one :responsible, through: :department_responsible, source: :user, inverse_of: false

  validates :name, presence: true
  validates :initials, presence: true, uniqueness: true
  validates :local, presence: true
  validates_email_format_of :email, message: I18n.t('errors.messages.invalid')
  validates :email, uniqueness: true
  validates :phone, format: { with: /\A\(\d{2}\)\s\d{4,5}-\d{4}\z/ }

  def modules
    department_modules
  end

  def user_is_collaborator?(user)
    department_users.find_by(user_id: user.id).role.eql?('collaborator')
  end
end
