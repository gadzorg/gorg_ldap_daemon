#!/usr/bin/env ruby
# encoding: utf-8

class UpdateAccountMessageHandler < GorgService::Consumer::MessageHandler::RequestHandler

  listen_to "request.ldapd.account.update"

  def validate_payload
    unless message.data[:uuid]
      Application.logger.error "Data validation error : INVALID UUID"
      raise_hardfail("Data validation error", error: {'INVALID UUID' => message.data[:uuid]})
    end
    Application.logger.debug "Message data validated"
  end

  def process
    set_uuid
    Application.logger.info("Received Account Update order for UUID : #{@uuid}")

    @gram_account=retrieve_gram_data

    @ldap_key=@gram_account.uuid
    Application.logger.debug("LDAPKey (uuid) = #{@ldap_key.inspect}")
    raise_invalide_ldap_key unless @ldap_key

    #update Account Attributes
    @ldap_account=LDAP::Account.find_or_build_by_uuid(@ldap_key)
    @ldap_account.assign_attributes_from_gram(@gram_account)
    Application.logger.debug("LDAP Account to be saved : #{@ldap_account.dn} : #{@ldap_account.attributes.inspect}")
    @ldap_account.save!
    Application.logger.info("Successfully updated account #{@uuid}")


    #update_group_membership
  end

  def update_group_membership
    target_groups=@gram_account.groups.map { |g| g.short_name }
    current_groups=@ldap_account.groups.map { |g| g.cn }

    to_add_groups_cn=target_groups-current_groups
    to_remove_groups_cn=current_groups-target_groups

    to_add_gram_groups=@gram_account.groups.select { |g| to_add_groups_cn.include?(g.short_name) }
    to_remove_ldap_groups=@ldap_account.groups.select { |g| to_remove_groups_cn.include?(g.cn) }

    @ldap_account.groups.delete(to_remove_ldap_groups)

    to_add_gram_groups.each do |gram_group|
      #check groups existence and create it if not
      ldap_group=LDAP::Group.find_or_build_by_name(gram_group.short_name)

      #TODO move this to LDAP::Group Model
      unless ldap_group.persisted?
        ldap_group.assign_attributes_from_gram(gram_group)
        ldap_group.save!
        Application.logger.info("Group #{gram_group.short_name} did not exist - created")
      end

      @ldap_account.groups<<ldap_group
    end
    Application.logger.info("#{@uuid} removed from group #{to_remove_groups_cn.join(", ")}") if to_remove_groups_cn.any?
    Application.logger.info("#{@uuid} added to group #{to_add_groups_cn.join(", ")}") if to_add_groups_cn.any?
  end

  def retrieve_gram_data
    begin
      #retrieve data from Gram, with password
      GramV2Client::Account.find(@uuid, params: {show_password_hash: "true"})

    rescue GramV2Client::ResourceNotFound => e
      Application.logger.error("Account not found in Gram - UUID= #{@uuid}")
      raise_hardfail("Account not found in Gram - UUID= #{@uuid}", error:e)
    end
  end

  def set_uuid
    @uuid=message.data[:uuid]
    unless @uuid
      #TODO handle null hruid, maybe by validating the message JSON
    end
  end

  def raise_invalide_ldap_key
    Application.logger.error("The following ldap key #{@ldap_key.inspect} is invalid")
    raise_hardfail("Invalid data in GrAM - ldap primary key = #{@ldap_key.inspect}")
  end

  def raise_not_updated
    Application.logger.error("Unable to save : #{@ldap_account.errors.messages.inspect}")
    raise_hardfail("Invalid data in GrAM - #{@ldap_account.errors.messages.inspect}")
  end

end
