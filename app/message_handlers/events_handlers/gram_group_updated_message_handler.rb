class GramGroupUpdatedMessageHandler < GorgService::Consumer::MessageHandler::Base

  listen_to "notify.group.updated"
  listen_to "notify.group.created"

  def initialize incoming_msg
    proxy_msg=incoming_msg.dup
    proxy_msg.data=incoming_msg.data.dup
    proxy_msg.data[:uuid]=proxy_msg.data[:key]
    proxy_msg.data[:cn]=proxy_msg.data[:changes][:short_name][1]
    UpdateGroupMessageHandler.new proxy_msg
  end
  
end