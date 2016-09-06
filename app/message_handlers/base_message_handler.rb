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

  def initialize incoming_msg
    @msg=incoming_msg

    begin
      begin

        # validate_payload method should be implemented by children classes
        validate_payload

        # process method must be implemented by children classes
        process

      rescue ActiveLdap::ConnectionError
        raise_ldap_connection_error
      end

    rescue GorgService::HardfailError, GorgService::SoftfailError
      raise
    
    rescue StandardError => e
      GorgLdapDaemon.logger.error "Uncatched exception : #{e.inspect}"
      raise_hardfail("Uncatched exception", error: e.as_json)
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
    GorgLdapDaemon.logger.error("#{self.class} doesn't implement process()")
    raise_hardfail("#{self.class} doesn't implement process()", UnimplementedMessageHandlerError)
  end

  # validate_payload MAY be implemented
  # If not, assumes messages is valid, log a warning and returns true
  def validate_payload
    GorgLdapDaemon.logger.warn("#{self.class} doesn't validate_payload(), assume payload is valid")
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

  # To be raised in case of connection errors with Gram API server
  def raise_gram_connection_error(error: nil)
    GorgLdapDaemon.logger.error("Unable to connect to GrAM API server")
    raise_softfail("Unable to connect to GrAM API server", error: error.as_json)
  end


  def raise_ldap_account_not_found(key,value)
    GorgLdapDaemon.logger.error("Account not found in LDAP - #{key}= #{value}")
    raise_hardfail("Account not found in LDAP - #{key}= #{value}",error: LdapObjectNotFoundError)
  end

  def raise_gram_account_not_found(value, error: nil)
    GorgLdapDaemon.logger.error("Account not found in Gram - UUID= #{value}")
    raise_hardfail("Account not found in Gram - UUID= #{value}", error:(error.as_json||GramAccountNotFoundError))
  end

  def raise_not_updated_group(ldap_group)
    GorgLdapDaemon.logger.error("Unable to save group #{ldap_group.cn} : #{ldap_group.errors.messages.inspect}")
    raise_hardfail("Unable to save group #{ldap_group.cn} : #{ldap_group.errors.messages.inspect}")
  end
end

## Error classes

class InvalidPayloadError < StandardError; end
class UnimplementedMessageHandlerError < StandardError; end
class LdapObjectNotFoundError < StandardError; end
class GramAccountNotFoundError < StandardError; end