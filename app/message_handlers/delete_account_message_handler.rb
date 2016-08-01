#!/usr/bin/env ruby
# encoding: utf-8

require 'byebug'

class DeleteAccountMessageHandler < BaseMessageHandler
  # Respond to routing key: request.gapps.create

  def process
    set_uuid
    GorgLdapDaemon.logger.info("Received Account Delete order for UUID : #{@uuid}")

    @account=LDAP::Account.find(attribute: :uuid,value: @uuid)

    if @account
      @account.delete
      GorgLdapDaemon.logger.info("Successfully deleted account #{@uuid}")
    else
      raise_ldap_account_not_found(:uuid, @uuid)
    end
  end

  def set_uuid
    @uuid=@msg.data[:uuid]
    unless @uuid
      #TODO handle null hruid, maybe by validating the message JSON
    end
  end
end