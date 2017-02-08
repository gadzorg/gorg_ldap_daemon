require File.expand_path('../../ldap.rb', __FILE__)
module LDAP
  class Group < LDAP::Base

    class NotFound < StandardError

      def initialize(query)
        @query=query
      end

      def to_s
        "Unable to find LDAP::Group from query #{@query}"
      end
    end

    ldap_mapping :dn_attribute => 'cn',
                 :classes => ['top', 'posixGroup'],
                 :prefix => 'ou=groupes',
                 :scope => :sub

    has_many :members, :wrap => "memberUid",
             :class_name => "LDAP::Account", :primary_key => 'dn'


    def assign_attributes_from_gram(gram_data)
      self.assign_attributes({
                                 #:uuid           => gram_data.uuid,
                                 :cn => gram_data.short_name,
                             })
    end

    def self.find!(*args, &block)
      if result=self.find(*args, &block)
        result
      else
        raise NotFound.new(args)
      end
    end

    def self.find_or_build_by_name(cn)
      find(attribute: "cn", value: cn) || LDAP::Group.new(default_values)
    end


    def self.default_values
      {
          gidNumber: 9999
      }
    end

  end
end