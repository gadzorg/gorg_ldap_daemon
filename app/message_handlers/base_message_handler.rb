#!/usr/bin/env ruby
# encoding: utf-8


##Abstract class for payload validation and handling connectivity process
# Children classes should implement :
#  - process() : process the message stored in msg
#  - validate_payload() : method used to validate message's payload format
#                         Returns a boolean (true = valid, false = invalid)
#                         If not implemented, returns true
class BaseMessageHandler < GorgService::MessageHandler
  # Respond to routing key: request.gapps.create

  def initialize _msg
    @msg=_msg

    # validate_payload method should be implemented by children classes
    validate_payload

    begin
      # process method should be implemented by children classes
      process
    rescue ActiveLdap::ConnectionError
      raise_ldap_connection_error
    end
  end

  #convenience method
  def msg
    @msg
  end

  ## Children implemented methods

  # process MUST be implemented
  # If not, raise hardfail
  def process
    GorgLdapDaemon.logger.error("#{self.class.to_s} doesn't implement process()")
    raise_hardfail("#{self.class.to_s} doesn't implement process()", UnimplementedMessageHandlerError)
  end

  # validate_payload MAY be implemented
  # If not, assumes messages is valid, log a warning and returns true
  def validate_payload
    GorgLdapDaemon.logger.warn("#{self.class.to_s} doesn't validate_payload(), assume payload is valid")
    true
  end


  ## Errors management

  # To be raised in case of connection errors with LDAP
  def raise_ldap_connection_error
    # ActiveLdap has an internal retry count that we need to set to 0 in order to be able
    # to try again when the next message is received
    # We clean the connections so ActiveLdap will create a new one with a new counter
    ActiveLdap::Base.clear_active_connections!
    GorgLdapDaemon.logger.error("Unable to connect to LDAP server")
    raise_softfail("Unable to connect to LDAP server")
  end

  def raise_ldap_account_not_found(key,value)
    GorgLdapDaemon.logger.error("Account not found in LDAP - #{key}= #{value}")
    raise_softfail("Account not found in LDAP - #{key}= #{value}",error: LdapObjectNotFoundError)
  end
end

## Error classes

class InvalidPayloadError < StandardError; end
class UnimplementedMessageHandlerError < StandardError; end
class LdapObjectNotFoundError < StandardError; end