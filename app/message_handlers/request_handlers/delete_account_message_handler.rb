#!/usr/bin/env ruby
# encoding: utf-8

class DeleteAccountMessageHandler < GorgService::Consumer::MessageHandler::RequestHandler

  listen_to "request.ldapd.account.delete"

  def process
    set_uuid
    Application.logger.info("Received Account Delete order for UUID : #{@uuid}")
    @account=LDAP::Account.find!(attribute: :uuid, value: @uuid)
    @account.destroy
    Application.logger.info("Successfully deleted account #{@uuid}")
  end

  def set_uuid
    @uuid=message.data[:uuid]
    unless @uuid
      #TODO handle null hruid, maybe by validating the message JSON
    end
  end
end