module LDAP
  class Base < ActiveLdap::Base
    def prefix
      (self.dn-self.base).to_s
    end
  end
end