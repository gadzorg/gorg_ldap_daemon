#!/usr/bin/env ruby
# encoding: utf-8

class DeleteGroupMessageHandler < GorgService::Consumer::MessageHandler::RequestHandler

  listen_to "request.ldapd.group.delete"

  def process
    set_cn
    Application.logger.info("Received Group Delete order for cn : #{@cn}")
    @group=LDAP::Group.find!(attribute: :cn, value: @cn)
    @group.destroy
    Application.logger.info("Successfully deleted group #{@cn}")

  end

  def set_cn
    @cn=message.data[:cn]
    unless @cn
      #TODO handle null hruid, maybe by validating the message JSON
    end
  end
end