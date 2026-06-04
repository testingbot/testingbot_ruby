require "digest"

RSpec.describe TestingBot::Api, "#get_authentication_hash" do
  include_context "recording api"

  it "returns MD5(key:secret:identifier) without raising (require 'digest' is loaded)" do
    expect(api.get_authentication_hash("abc"))
      .to eq(Digest::MD5.hexdigest("mykey:mysecret:abc"))
  end
end
