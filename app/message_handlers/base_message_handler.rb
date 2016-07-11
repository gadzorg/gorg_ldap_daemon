#!/usr/bin/env ruby
# encoding: utf-8

class BaseMessageHandler < GorgService::MessageHandler
  # Respond to routing key: request.gapps.create

  def initialize msg
    @msg=msg
    begin
      process
    rescue ActiveLdap::ConnectionError
      raise_ldap_connection_error
    end
  end

  def raise_ldap_connection_error
    # ActiveLdap has an internal retry count that we need to set to 0 in order to be able
    # to try again when the next message is received
    # We clean the connections so ActiveLdap will create a new one with a new counter
    ActiveLdap::Base.clear_active_connections!

    raise_softfail("Unable to connect to LDAP server")
  end

  def process
    GorgLdapDaemon.logger.error("#{self.class.to_s} doesn't implement process()")
    raise_hardfail("#{self.class.to_s} doesn't implement process()")
  end
end