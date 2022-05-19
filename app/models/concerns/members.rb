module Members
  extend ActiveSupport::Concern

  included do
    def search_non_members(term)
      User.where('unaccent(name) ILIKE unaccent(?)', "%#{term}%").order('name ASC').where.not(id: user_ids)
    end

    def members
      relationship.includes(:user)
    end

    def add_member(user)
      relationship.create(user).valid?
    end

    def remove_member(user_id)
      relationship.find_by(user_id: user_id).destroy
    end

    private

    def relationship
      send("#{self.class.name.underscore}_users".to_sym)
    end
  end
end
