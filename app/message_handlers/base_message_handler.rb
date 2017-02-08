#!/usr/bin/env ruby
# encoding: utf-8

class GorgService::Consumer::MessageHandler::Base

  # To be raised in case of connection errors with LDAP
  handle_error ActiveLdap::ConnectionError do |error,_message|
      # ActiveLdap has an internal retry count that we need to set to 0 in order to be able
      # to try again when the next message is received
      # We clean the connections so ActiveLdap will create a new one with a new counter
      ActiveLdap::Base.clear_active_connections!
      Application.logger.error("Unable to connect to LDAP server")
      raise_softfail("LDAPConnectionError", error: error)
  end

  handle_error LDAP::Account::NotFound do |error,_message|
    Application.logger.error(error.inspect)
    raise_hardfail("LDAPAccountNotFound", error: error)
  end

  handle_error LDAP::Group::NotFound do |error,_message|
    Application.logger.error(error.inspect)
    raise_hardfail("LDAPGroupNotFound", error: error)
  end

  handle_error ActiveResource::ServerError do |error,_message|
    Application.logger.error("Unable to connect to GrAM API server")
    raise_softfail("GramConnectionError", error: error)
  end

  handle_error ActiveLdap::EntryInvalid do |error,_message|
    Application.logger.error("Attributs  LDAP invalides : #{error.inspect}")
    raise_hardfail("Ldap::EntryInvalid", error: error)
  end

end
