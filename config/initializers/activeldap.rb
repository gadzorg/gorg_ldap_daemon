require 'active_ldap'

ActiveLdap::Base.setup_connection host: Application.config["ldap_host"],
                                  base: Application.config["ldap_base"],
                                  port: Application.config["ldap_port"],
                                  bind_dn: Application.config["ldap_bind_dn"],
                                  password: Application.config["ldap_password"],
                                  logger: Application.logger,
                                  method: (Application.config["ldap_connection_method"] && Application.config["ldap_connection_method"].to_sym)||:plain,
                                  retry_limit: 0,
                                  retry_wait: 0