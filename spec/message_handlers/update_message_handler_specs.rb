require 'spec_helper'

RSpec.describe UpdateAccountMessageHandler, type: :message_handler do

  describe "existing account" do    
    context "valid attributes" do
      it "update account" do
        mock_ldap_account = instance_double("LDAP::Account",
          :update_attributes => true)

        expect(LDAP::Account).to receive(:find).with(attribute: "uuid", value: "12345678-1234-1234-1234-123456789012") {mock_ldap_account}
        expect(mock_ldap_account).to receive(:update_attributes).with({:uuid=>"12345678-1234-1234-1234-123456789012",
          :idSoce=>157157,
          :hruid=>"alexandre.narbonne.ext.157",
          :prenom=>"Alexandre",
          :nom=>"Narbonne",
          :actif=>true,
          :gidNumber=>158157,
          :uid=>"158157",
          :uidNumber=>158157,
          :emailCompte=>"alexandre.narbonne@poubs.org",
          :emailForge=>"alexandre.narbonne@poubs.org"
        }
       )
       UpdateAccountMessageHandler.new(double(:data => {uuid: "12345678-1234-1234-1234-123456789012"}))
      end
    end

    context "invalid attributes" do
      it "raise a Hardfail" do
        mock_ldap_account = instance_double("LDAP::Account",
          :update_attributes => false,
          :errors => double("errors", :messages => "une erreur"))

        expect(LDAP::Account).to receive(:find).with(attribute: "uuid", value: "12345678-1234-1234-1234-123456789012") {mock_ldap_account}

        expect {UpdateAccountMessageHandler.new(double(:data => {uuid: "12345678-1234-1234-1234-123456789012"}))}.to raise_error(GorgService::HardfailError)
      end
    end
  end
end