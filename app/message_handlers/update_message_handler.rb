#!/usr/bin/env ruby
# encoding: utf-8

class UpdateMessageHandler < GorgService::MessageHandler
  # Respond to routing key: request.gapps.create

  def initialize msg
    id=msg.data[:id_soce]
    if LDAP::Account.exists?(id)
      puts " [x] Account n°#{id} exists"
    else
      puts " [x] Account n°#{id} doesn't exist yet"
    end

    #TODO Serialize gram data in hash and pass to LDAP with update_attributes or create
  end
end