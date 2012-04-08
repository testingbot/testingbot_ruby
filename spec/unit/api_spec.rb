require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../../lib/testingbot/config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/testingbot/api.rb')

describe TestingBot::Api do
  describe "load config" do
  	it "should load the configuration in the constructor" do
  		api = TestingBot::Api.new
      api.instance_variable_get("@config").should_not be_nil
  	end

    it "should use the credentials passed in from the constructor, overwriting possible credentials from the config" do
      api = TestingBot::Api.new({ :client_key => "fake" })
      api.instance_variable_get("@config")[:client_key].should eql("fake")
    end
  end
end