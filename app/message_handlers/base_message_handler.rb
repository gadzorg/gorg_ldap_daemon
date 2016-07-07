#!/usr/bin/env ruby
# encoding: utf-8

class BaseMessageHandler < GorgService::MessageHandler
  # Respond to routing key: request.gapps.create

  def initialize msg
    @msg=msg
    process
  end

  def process
    GorgLdapDaemon.logger.error("#{self.class.to_s} doesn't implement process()")
  end
end