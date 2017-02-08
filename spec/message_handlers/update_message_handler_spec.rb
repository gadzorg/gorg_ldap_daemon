require 'spec_helper'

RSpec.describe UpdateAccountMessageHandler, type: :message_handler do

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
                                password: "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8",
                                aliases: [double({name: "groupe1"}),double({name: "groupe3"})],
                                groups: [],
                                )
      }

    context "valid attributes" do

      let(:mocked_ldap_account) { instance_double("LDAP::Account",
                                                  :assign_attributes_from_gram => true,
                                                  :save! => true,
                                                  :groups => [],
                                                  :attributes => [],
                                                  :dn => "someDn",
                                                  )
        }

      it "update account" do

        expect(LDAP::Account).to receive(:find_or_build_by_uuid).with("12345678-1234-1234-1234-123456789012").and_return(mocked_ldap_account)
        expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}
        expect(mocked_ldap_account).to receive(:assign_attributes_from_gram).with(mocked_gram_account)

       UpdateAccountMessageHandler.new(double(expect_reply?: false,:data => {uuid: "12345678-1234-1234-1234-123456789012"}))
      end

      describe "Connection errors" do
        it "softfail on ldap connection error" do
          expect(LDAP::Account).to receive(:find_or_build_by_uuid).with("12345678-1234-1234-1234-123456789012").and_raise(ActiveLdap::ConnectionError)
          expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}

          expect {UpdateAccountMessageHandler.new(double(expect_reply?: false,:data => {uuid: "12345678-1234-1234-1234-123456789012"}))}.to raise_error(GorgService::Consumer::SoftfailError)
        end

        it "softfail on GrAM connection error" do
          #expect(LDAP::Account).to receive(:find_or_build_by_uuid).with("12345678-1234-1234-1234-123456789012").and_return(mocked_ldap_account)
          expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}).and_raise(ActiveResource::ServerError.new("plop"))

          expect {UpdateAccountMessageHandler.new(double(expect_reply?: false,:data => {uuid: "12345678-1234-1234-1234-123456789012"}))}.to raise_error(GorgService::Consumer::SoftfailError)
        end

      end

      # describe "group membership" do
      #   let(:mocked_gram_account) { double("GramV2Client::Account",
      #                                       :uuid => "12345678-1234-1234-1234-123456789012",
      #                                       id_soce: 157157,
      #                                       hruid: "georges.dupont.1965",
      #                                       id: 53,
      #                                       enabled: true,
      #                                       lastname: "Dupont",
      #                                       firstname: "Georges",
      #                                       email: "georges.dupont@poubs.org",
      #                                       gapps_email: "georges.dupont@poubs.org",
      #                                       gender: "male",
      #                                       is_gadz: true,
      #                                       is_student: false,
      #                                       school_id: "1965-1234",
      #                                       is_alumni: true,
      #                                       buque_texte: "buckor",
      #                                       buque_zaloeil: "Buckor",
      #                                       gadz_fams: "157",
      #                                       gadz_fams_zaloeil: "157" ,
      #                                       gadz_proms_principale: "me165",
      #                                       password: "5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8",
      #                                       alias: [double({name: "groupe1"}),double({name: "groupe3"})],
      #                                       groups: [double("GramV2Client::Group",
      #                                                                 "uuid"=>"a7e047e0-5e2e-43bf-ab85-42d6c27e0e80",
      #                                                                 "short_name"=>"goblins",
      #                                                                 "name"=>"Goblins Company !",
      #                                                                 "description"=>"Innovative even-keeled infrastructure",
      #                                                                 "url"=>"/api/v2/groups/a7e047e0-5e2e-43bf-ab85-42d6c27e0e80")],
      #                                     )
      #    }
      #
      #    let(:new_ldap_group) {double(persisted?: false, save: true, assign_attributes_from_gram: true)}
      #    let(:members_association) {double(:<< => true)}
      #    let(:existing_ldap_group) {double(persisted?: true, save: true, assign_attributes_from_gram: true, :members => members_association)}
      #
      #   it "create group" do
      #     expect(GramV2Client::Account).to receive(:find!).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}
      #     expect(LDAP::Account).to receive(:find_or_build_by_uuid).with("12345678-1234-1234-1234-123456789012") {mocked_ldap_account}
      #     expect(LDAP::Group).to receive(:find_or_build_by_name).with("goblins") {new_ldap_group}
      #
      #
      #     expect(new_ldap_group).to receive(:save)
      #     UpdateAccountMessageHandler.new(double(:data => {uuid: "12345678-1234-1234-1234-123456789012"}))
      #   end
      #
      #   it "doesn't update existing groups" do
      #     expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}
      #     expect(LDAP::Account).to receive(:find_or_build_by_uuid).with("12345678-1234-1234-1234-123456789012") {mocked_ldap_account}
      #     expect(LDAP::Group).to receive(:find_or_build_by_name).with("goblins") {existing_ldap_group}
      #     expect(existing_ldap_group).not_to receive(:save)
      #     UpdateAccountMessageHandler.new(double(:data => {uuid: "12345678-1234-1234-1234-123456789012"}))
      #   end
      #
      #   it "add membership" do
      #     expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}
      #     expect(LDAP::Account).to receive(:find_or_build_by_uuid).with("12345678-1234-1234-1234-123456789012") {mocked_ldap_account}
      #     expect(LDAP::Group).to receive(:find_or_build_by_name).with("goblins") {existing_ldap_group}
      #
      #     expect(members_association).not_to receive(:<<)
      #
      #     UpdateAccountMessageHandler.new(double(:data => {uuid: "12345678-1234-1234-1234-123456789012"}))
      #   end
      #
      # end

    end

    context "invalid attributes" do
      it "raise a Hardfail" do
        mock_ldap_account = instance_double("LDAP::Account",
          :assign_attributes_from_gram => true,
          :save => false,
          :attributes => [],
          :dn => "someDn",
          :errors => double("errors", :messages => ["une erreur"],:full_messages => ["une erreur"]))

        allow(mock_ldap_account).to receive(:save!).and_raise(ActiveLdap::EntryInvalid.new(mock_ldap_account))
        expect(LDAP::Account).to receive(:find_or_build_by_uuid).with("12345678-1234-1234-1234-123456789012").and_return(mock_ldap_account)
        #expect(LDAP::Account).to receive(:find).with(attribute: "uuid", value: "12345678-1234-1234-1234-123456789012").and_return(mock_ldap_account)
        expect(GramV2Client::Account).to receive(:find).with("12345678-1234-1234-1234-123456789012", {:params=>{:show_password_hash=>"true"}}) {mocked_gram_account}

        expect {UpdateAccountMessageHandler.new(double(:expect_reply? => false,:data => {uuid: "12345678-1234-1234-1234-123456789012"}))}.to raise_error(GorgService::Consumer::HardfailError)
      end
    end
end