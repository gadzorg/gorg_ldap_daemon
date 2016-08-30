#!/usr/bin/env ruby
# encoding: utf-8

class UpdateAccountMessageHandler < BaseMessageHandler
  # Respond to routing key: request.gapps.create

  def process
    set_uuid
    GorgLdapDaemon.logger.info("Received Account Update order for UUID : #{@uuid}")

    @gram_account=retrieve_gram_data

    @ldap_key=@gram_account.uuid
    GorgLdapDaemon.logger.debug("LDAPKey (uuid) = #{@ldap_key.inspect}")
    raise_invalide_ldap_key unless @ldap_key

    #update Account Attributes
    @ldap_account=LDAP::Account.find_or_build_by_uuid(@ldap_key)
    @ldap_account.assign_attributes_from_gram(@gram_account)
    GorgLdapDaemon.logger.debug("LDAP Account to be saved : #{@ldap_account.dn} : #{@ldap_account.attributes.inspect}")
    if @ldap_account.save
      GorgLdapDaemon.logger.info("Successfully updated account #{@uuid}")
    else
      raise_not_updated
    end

    update_group_membership
  end

  def update_group_membership
    target_groups=@gram_account.groups.map{|g| g.short_name}
    current_groups=@ldap_account.groups.map{|g| g.cn}

    to_add_groups_cn=target_groups-current_groups
    to_remove_groups_cn=current_groups-target_groups

    to_add_gram_groups=@gram_account.groups.select{|g| to_add_groups_cn.include?(g.short_name)}
    to_remove_ldap_groups=@ldap_account.groups.select{|g| to_remove_groups_cn.include?(g.cn)}

    @ldap_account.groups.delete(to_remove_ldap_groups)

    to_add_gram_groups.each do |gram_group|
      #check groups existence and create it if not
      ldap_group=LDAP::Group.find_or_build_by_name(gram_group.short_name)

      #TODO move this to LDAP::Group Model
      unless ldap_group.persisted?
        ldap_group.assign_attributes_from_gram(gram_group)
        if ldap_group.save
          GorgLdapDaemon.logger.info("Group #{gram_group.short_name} did not exist - created")
        else
          raise_not_updated_group(ldap_group)
        end
      end

      @ldap_account.groups<<ldap_group
    end
    GorgLdapDaemon.logger.info("#{@uuid} removed from group #{to_remove_groups_cn.join(", ")}") if to_remove_groups_cn.any?
    GorgLdapDaemon.logger.info("#{@uuid} added to group #{to_add_groups_cn.join(", ")}") if to_add_groups_cn.any?
  end

  def retrieve_gram_data
    begin
      #retrieve data from Gram, with password
      GramV2Client::Account.find(@uuid, params:{show_password_hash: "true"})

    rescue ActiveResource::ResourceNotFound
      raise_gram_account_not_found(@uuid)
    rescue ActiveResource::ServerError
      raise_gram_connection_error
    end
  end 

  def set_uuid
    @uuid=msg.data[:uuid]
    unless @uuid
      #TODO handle null hruid, maybe by validating the message JSON
    end
  end

  def raise_invalide_ldap_key
    GorgLdapDaemon.logger.error("The following ldap key #{@ldap_key.inspect} is invalid")
    raise_hardfail("Invalid data in GrAM - ldap primary key = #{@ldap_key.inspect}")
  end

  def raise_not_updated
    GorgLdapDaemon.logger.error("Unable to save : #{@ldap_account.errors.messages.inspect}")
    raise_hardfail("Invalid data in GrAM - #{@ldap_account.errors.messages.inspect}")
  end

end