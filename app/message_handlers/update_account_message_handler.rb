#!/usr/bin/env ruby
# encoding: utf-8

require 'byebug'

class UpdateAccountMessageHandler < BaseMessageHandler
  # Respond to routing key: request.gapps.create

  def process
    set_uuid
    GorgLdapDaemon.logger.info("Received Account Update order for UUID : #{@uuid}")

    @data=retrieve_gram_data

    @ldap_key=@data.uuid
    GorgLdapDaemon.logger.debug("LDAPKey (uuid) = #{@ldap_key.inspect}")
    raise_invalide_ldap_key unless @ldap_key

    @account=LDAP::Account.find(attribute: "uuid", value: @ldap_key)
    @account||=LDAP::Account.new(default_values)
    @account.assign_attributes(attributes_mapping)
 
    if @account.save
      GorgLdapDaemon.logger.info("Successfully updated account #{@uuid}")
    else
      raise_not_updated
    end
  end

  def retrieve_gram_data
    begin
      # GorgLdapDaemon.logger.debug("Use mockup API")
      # MockupGramAccount.new ({
      #   uuid:@uuid,
      #   id_soce: 157157,
      #   hruid: "alexandre.narbonne.ext.157",
      #   id: 53,
      #   enabled: true,
      #   lastname: "Narbonne",
      #   firstname: "Alexandre",
      #   email: "alexandre.narbonne@poubs.org",
      #   gapps_email: "alexandre.narbonne@poubs.org",
      #   #password:"",
      #   gender: "male",
      #   is_gadz: true,
      #   is_student: false,
      #   school_id: "2011-1882",
      #   is_alumni: true,
      #   buque_texte: "ratatosk",
      #   buque_zaloeil: "Ratatosk",
      #   gadz_fams: "157",
      #   gadz_fams_zaloeil: "157" ,
      #   gadz_proms_principale: "me211",
      # })

      #retrieve data from Gram, with password
      GramV2Client::Account.find(@uuid, params:{show_password_hash: "true"})

    rescue ActiveResource::ResourceNotFound
      raise_gram_account_not_found(@uuid)
    rescue ActiveResource::ServerError
      raise_gram_connection_error
    end
  end

  def default_values
    {
      descriptionCompte: "Created by LdapDaemon at #{DateTime.now.to_s}",
      homeDirectory: '/nonexistant',
      loginValidationCheck: "CGU=;",
      dn:"hruid=#{@data.hruid},ou=comptes,ou=gram,dc=gadz,dc=org"
    }
  end

  def attributes_mapping
    uid_number= @data.id_soce+1000

    {
      :uuid           => @data.uuid,
      :idSoce         => @data.id_soce,
      :hruid          => @data.hruid,
      :prenom         => @data.firstname,
      :nom            => @data.lastname,
      :actif          => @data.enabled,
      :gidNumber      => uid_number,
      :uid            => uid_number.to_s,
      :uidNumber      => uid_number,
      :emailCompte    => @data.email,
      :emailForge     => @data.email,
      :userPassword   => convert_password_to_ldap_format(@data.password)
    }
  end


  #Take a sha1 hex string in input
  #ex : 5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8
  #returns a base64 encoded value prefixed with {SHA}
  def convert_password_to_ldap_format passwd
    #convert hexsha1 string to its binary string
    binary_value=[passwd].pack('H*')
    #base64 encoding
    b64_hash=Base64.encode64(binary_value).chomp!
    #prefix with '{SHA}'
    return "{SHA}#{b64_hash}"
  end

  def set_uuid
    @uuid=msg.data[:uuid]
    unless @uuid
      #TODO handle null hruid, maybe by validating the message JSON
    end
  end

  def raise_invalide_ldap_key
    GorgLdapDaemon.logger.error("The following ldap key '#{@ldap_key.to_s}' is invalid")
    raise_hardfail("Invalid data in GrAM - ldap primary key = #{@ldap_key.inspect}")
  end

  def raise_not_updated
    GorgLdapDaemon.logger.error("Unable to save : #{@account.errors.messages.inspect}")
    raise_hardfail("Invalid data in GrAM - #{@account.errors.messages.inspect}")
  end

end