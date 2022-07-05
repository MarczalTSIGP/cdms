class DepartmentUser < ApplicationRecord
  include Roleable

  belongs_to :department, counter_cache: true
  belongs_to :user

  validates :role, inclusion: { in: DepartmentUser.roles.values }
  validates :user, uniqueness: { scope: :department_id }
  validate :only_one_responsible, if: :responsible_role?

  private

  def only_one_responsible
    return if department.department_users.responsible_role.count.zero?

    errors.add(:role, I18n.t('errors.messages.taken'))
  end
end
