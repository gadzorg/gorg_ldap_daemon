class GramAccountDeletedMessageHandler < GorgService::MessageHandler
  # Respond to routing key: request.gapps.create

  def initialize incoming_msg
    proxy_msg=incoming_msg.dup
    proxy_msg.data=incoming_msg.data.dup
    proxy_msg.data[:uuid]=proxy_msg.data[:key]
    DeleteAccountMessageHandler.new proxy_msg
  end
  
end