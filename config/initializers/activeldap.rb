ActiveLdap::Base.setup_connection host: GorgLdapDaemon.config["ldap_host"],
                                  base: GorgLdapDaemon.config["ldap_base"],
                                  port: GorgLdapDaemon.config["ldap_port"],
                                  bind_dn: GorgLdapDaemon.config["ldap_bind_dn"],
                                  password: GorgLdapDaemon.config["ldap_password"]