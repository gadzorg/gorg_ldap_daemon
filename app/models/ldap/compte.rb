class LDAP::Account < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'idSoce',
               :classes => ['Compte'],
               :prefix => 'ou=comptes',
               :scope => :one
end