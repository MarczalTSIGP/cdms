class DocumentReceiver
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user, :user_id, :document_id

  validates :user, :user_id, presence: true
  validate :user_id_exists

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def save
    return false unless valid?

    document = Document.find(document_id)
    document.add_user(user_id)
  end

  private

  def user_id_exists
    document_user = User.find_by(id: @user_id)
    errors.add(:user, 'não existente') if document_user.nil?
  end
end
