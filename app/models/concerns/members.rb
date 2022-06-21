module Members
  extend ActiveSupport::Concern

  module ClassMethods
    private

    def build_member_methods(options = {})
      BuilderMethods.new(self, options).build
    end
  end

  class BuilderMethods
    def initialize(object, options)
      @object = object
      @options = options
    end

    def build
      builder = self

      @object.instance_eval do
        builder.build_members_method(self)
        builder.build_add_member_method(self)
        builder.build_remove_member_method(self)
        builder.build_search_non_members_method(self)
      end

      @object.alias_method "search_non_#{method_name.pluralize}".to_sym, :search_non_members
    end

    def build_members_method(instance)
      builder = self
      instance.define_method(method_name.pluralize) do
        send(builder.relationship).includes(:user)
      end
    end

    def build_add_member_method(instance)
      builder = self
      instance.define_method("add_#{method_name}") do |member|
        send(builder.relationship).create(member).valid?
      end
    end

    def build_remove_member_method(instance)
      builder = self
      instance.define_method("remove_#{method_name}") do |member_id|
        send(builder.relationship).find_by(user_id: member_id).destroy
      end
    end

    def build_search_non_members_method(instance)
      builder = self
      instance.define_method(:search_non_members) do |term|
        member_ids = send("#{builder.relationship_name.singularize}_ids")
        User.where('unaccent(name) ILIKE unaccent(?)', "%#{term}%")
            .order('name ASC')
            .where.not(id: member_ids)
      end
    end

    def relationship
      "#{@object.name.underscore}_#{relationship_name}"
    end

    def relationship_name
      @options[:relationship].to_s
    end

    def method_name
      @options[:name].to_s
    end
  end
end
