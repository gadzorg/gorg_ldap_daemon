class GramGroupDeletedMessageHandler < GorgService::Consumer::MessageHandler::Base

  listen_to "notify.group.deleted"

  def initialize incoming_msg
    proxy_msg=incoming_msg.dup
    proxy_msg.data=incoming_msg.data.dup
    proxy_msg.data[:uuid]=proxy_msg.data[:key]
    DeleteGroupMessageHandler.new proxy_msg
  end
  
end