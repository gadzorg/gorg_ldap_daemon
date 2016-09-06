class GramAccountUpdatedMessageHandler < GorgService::MessageHandler
  # Respond to routing key: request.gapps.create

  def initialize incoming_msg
    proxy_msg=incoming_msg.dup
    proxy_msg.data=incoming_msg.data.dup
    proxy_msg.data[:uuid]=proxy_msg.data[:key]
    byebug
    UpdateAccountMessageHandler.new proxy_msg
  end

end