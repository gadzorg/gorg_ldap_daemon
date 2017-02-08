#!/usr/bin/env ruby
# encoding: utf-8

class UpdateGroupMessageHandler < GorgService::Consumer::MessageHandler::RequestHandler

  listen_to "request.ldapd.group.update"

  def process
    set_data
    @cn=@data[:cn]
    Application.logger.info("Received Group Update order for cn=#{@cn}")

    @group=LDAP::Group.find_or_build_by_name(@cn)
    @group.cn=@data[:cn]
    #@group.uuid=@data[:uuid]

    @group.save!
    Application.logger.info("Group cn=#{@cn} updated")
    update_members

  end

  def update_members
    if @data[:members]

      current_members=@group.members
      current_members_uuid=current_members.map { |u| u.uuid }

      target_members_uuid=@data[:members]||[]

      to_add_uuids=target_members_uuid-current_members_uuid
      to_remove_uuids=current_members_uuid-target_members_uuid

      to_remove_uuids.each do |uuid|
        @group.members.delete LDAP::Account.find(uuid)
      end

      Application.logger.info("removed #{to_remove_uuids.count} members to group cn=#{@cn}")


      new_members=[]
      to_add_uuids.each do |uuid|
        member=LDAP::Account.find!(attribute: :uuid, value: uuid)
        new_members<<member
      end
      @group.members << new_members
      Application.logger.info("added #{to_add_uuids.count} members to group cn=#{@cn}")
    end
  end

  def set_data
    @data=message.data
  end
end