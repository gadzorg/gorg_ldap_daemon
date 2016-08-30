require File.expand_path('../../ldap.rb', __FILE__)
module LDAP
  class Role < LDAP::Base 
    ldap_mapping :dn_attribute => 'roleName',
                 :classes => ['top','roleSI'],
                 :prefix => 'ou=comptes',
                 :scope => :sub

  end
end