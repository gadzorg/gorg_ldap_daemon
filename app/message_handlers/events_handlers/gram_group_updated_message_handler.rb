class GramGroupUpdatedMessageHandler < GorgService::Consumer::MessageHandler::Base

  listen_to "notify.group.updated"
  listen_to "notify.group.created"

  def initialize incoming_msg
    proxy_msg=incoming_msg.dup
    proxy_msg.data=incoming_msg.data.dup
    proxy_msg.data[:uuid]=proxy_msg.data[:key]
    changes=proxy_msg.data[:changes]
    cn=changes[:short_name]&&changes[:short_name][1]
    raise_hardfail("UnprocessableEvent", error: "No cn") unless cn
    proxy_msg.data[:cn]=cn
    UpdateGroupMessageHandler.new proxy_msg
  end
  
end