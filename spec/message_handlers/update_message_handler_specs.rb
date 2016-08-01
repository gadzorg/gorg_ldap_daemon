require 'spec_helper'

RSpec.describe UpdateAccountMessageHandler, type: :message_handler do

  describe "existing account" do    
    let(:mocked_gram_account) { double("GramV2Client::Account",
                                :uuid => "12345678-1234-1234-1234-123456789012",
                                id_soce: 157157,
                                hruid: "georges.dupont.1965",
                                id: 53,
                                enabled: true,
                                lastname: "Dupont",
                                firstname: "Georges",
                                email: "georges.dupont@poubs.org",
                                gapps_email: "georges.dupont@poubs.org",
                                password:"abcdefge",
                                gender: "male",
                                is_gadz: true,
                                is_student: false,
                                school_id: "1965-1234",
                                is_alumni: true,
                                buque_texte: "buckor",
                                buque_zaloeil: "Buckor",
                                gadz_fams: "157",
                                gadz_fams_zaloeil: "157" ,
                                gadz_proms_principale: "me165",
                                password: "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8"
                                )
      }

    context "valid attributes" do

      let(:mocked_ldap_account) { instance_double("LDAP::Account",
                                                  :assign_attributes => true,
                                                  :save => true
                                                  )
        }

      it "update account" do

        expect(LDAP::Account).to receive(:find).with(attribute: "uuid", value: "12345678-1234-1234-1234-123456789012") {mocked_ldap_account}
        expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}
        expect(mocked_ldap_account).to receive(:assign_attributes).with({:uuid=>"12345678-1234-1234-1234-123456789012",
          :idSoce=>157157,
          :hruid=>"georges.dupont.1965",
          :prenom=>"Georges",
          :nom=>"Dupont",
          :actif=>true,
          :gidNumber=>158157,
          :uid=>"158157",
          :uidNumber=>158157,
          :emailCompte=>"georges.dupont@poubs.org",
          :emailForge=>"georges.dupont@poubs.org",
          :userPassword=>"{SHA}W6ph5Mm5Pz8GgiULbPgzG37mj9g="
        }
       )

       UpdateAccountMessageHandler.new(double(:data => {uuid: "12345678-1234-1234-1234-123456789012"}))
      end
    end

    context "invalid attributes" do
      it "raise a Hardfail" do
        mock_ldap_account = instance_double("LDAP::Account",
          :assign_attributes => true,
          :save => false,
          :errors => double("errors", :messages => "une erreur"))

        expect(LDAP::Account).to receive(:find).with(attribute: "uuid", value: "12345678-1234-1234-1234-123456789012") {mock_ldap_account}
        expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}

        expect {UpdateAccountMessageHandler.new(double(:data => {uuid: "12345678-1234-1234-1234-123456789012"}))}.to raise_error(GorgService::HardfailError)
      end
    end
  end
end