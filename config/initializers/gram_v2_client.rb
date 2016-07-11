require 'gram_v2_client'

GramV2Client.configure do |c|
  c.site=GorgLdapDaemon.config["gram_api_host"]
  c.user=GorgLdapDaemon.config["gram_api_user"]
  c.password=GorgLdapDaemon.config["gram_api_password"]
end