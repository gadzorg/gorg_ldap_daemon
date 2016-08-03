require 'spec_helper'

RSpec.describe RolesRegex, type: :model do

  it "returns a hash" do
    rrgex=RolesRegex.new
    expect(rrgex.to_h).to be_a_kind_of(Hash)
  end

  describe "parse data from gram" do

    it "parse 1 role" 

  end

end
