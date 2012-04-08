require "rspec"
require File.expand_path(File.dirname(__FILE__) + '/../../lib/testingbot/config.rb')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/testingbot/tunnel.rb')

describe TestingBot::Tunnel do
  describe "load config" do
  	it "should load the configuration in the constructor" do
  		tunnel = TestingBot::Tunnel.new
      tunnel.instance_variable_get("@config").should_not be_nil
  	end

    it "should should not overwrite the config with arguments supplied in the constructor" do
      tunnel = TestingBot::Tunnel.new({ :client_key => "fake" })
      tunnel.instance_variable_get("@config")[:client_key].should_not eql("fake")
    end

    it "should allow for extra options to be specified, which will be passed to the jar's argument list" do
      tunnel = TestingBot::Tunnel.new({ :options => ["-f readyfile.txt", "-F *.com"] })
      tunnel.extra_options.should eql("-f readyfile.txt -F *.com")
    end
  end

  describe "before starting the tunnel" do
    it "should have 0 errors" do
      tunnel = TestingBot::Tunnel.new
      tunnel.errors.should be_empty
    end

    it "should not be connected" do
      tunnel = TestingBot::Tunnel.new
      tunnel.is_connected?.should == false
    end
  end

  describe "before stopping the tunnel" do
    it "should check if the tunnel has been started yet" do
      tunnel = TestingBot::Tunnel.new
      lambda { tunnel.stop }.should raise_error(RuntimeError, /^Can't stop tunnel/)
    end
  end
end