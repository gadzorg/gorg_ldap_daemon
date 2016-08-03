#!/usr/bin/env ruby
# encoding: utf-8

class DeleteGroupMessageHandler < BaseMessageHandler
  # Respond to routing key: request.gapps.create

  def process
    set_cn
    GorgLdapDaemon.logger.info("Received Group Delete order for UUID : #{@cn}")

    @group=LDAP::Group.find(attribute: :cn,value: @cn)

    if @group
      @group.destroy
      GorgLdapDaemon.logger.info("Successfully deleted group #{@cn}")
    else
      raise_ldap_group_not_found(:cn, @cn)
    end
  end

  def set_cn
    @cn=@msg.data[:cn]
    unless @cn
      #TODO handle null hruid, maybe by validating the message JSON
    end
  end
end