require 'rspec'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Testingbot Tunnel" do
  after :each do
    @tunnel.stop if @tunnel.is_connected?
    TestingBot.reset_config!
  end

  context "the tunnel should start and block until it's ready" do
    it "should successfully start a tunnel connection" do 
      @tunnel = TestingBot::Tunnel.new()
      @tunnel.start
      @tunnel.is_connected?.should == true
    end

    it "should raise an exception when trying to stop a tunnel that has not been started yet" do
      @tunnel = TestingBot::Tunnel.new()
      lambda { @tunnel.stop }.should raise_error(RuntimeError, /not been started/)
    end
  end

  context "the tunnel needs to handle proper credentials" do
    it "should fail to start a tunnel connection when invalid credentials are supplied" do
      @tunnel = TestingBot::Tunnel.new({ :client_key => "fake", :client_secret => "bogus" })
      @tunnel.start
      @tunnel.is_connected?.should == false
      @tunnel.errors.should_not be_empty
      @tunnel.kill
    end

    it "should try to fetch client_key and client_secret from the ~/.testingbot file when no credentials supplied" do
      if File.exists?(File.expand_path("~/.testingbot"))
        @tunnel = TestingBot::Tunnel.new()
        @tunnel.start
        @tunnel.is_connected?.should == true
      end
    end
  end

  context "the tunnel needs to accept extra options" do
    it "should accept extra options" do
      if File.exists?(File.expand_path("~/testingbot_ready.txt"))
        File.delete(File.expand_path("~/testingbot_ready.txt"))
      end

      File.exists?(File.expand_path("~/testingbot_ready.txt")).should == false

      @tunnel = TestingBot::Tunnel.new({ :options => ['-f ~/testingbot_ready.txt'] })
      @tunnel.start
      @tunnel.is_connected?.should == true

      File.exists?(File.expand_path("~/testingbot_ready.txt")).should == true
    end
  end

  context "there should only be one instance of a tunnel running" do
    it "should check before starting that another tunnel is not yet running" do
      @tunnel = TestingBot::Tunnel.new
      @tunnel.start
      @tunnel.is_connected?.should == true

      clone = TestingBot::Tunnel.new
      clone.start
      clone.is_connected?.should == false
    end

    it "should not be possible to stop a tunnel that is not running" do
      @tunnel = TestingBot::Tunnel.new
      lambda { @tunnel.stop }.should raise_error(RuntimeError, /^Can't stop tunnel/)
    end
  end

  context "When running a tunnel config values should be changed" do
    it "should change the host and port in the config so that we connect to our tunnel instead of to the grid directly" do
      @tunnel = TestingBot::Tunnel.new
      @tunnel.start
      @tunnel.is_connected?.should == true
      @tunnel.instance_variable_get("@config")[:require_tunnel].should == true
      @tunnel.instance_variable_get("@config")[:host].should eql("127.0.0.1")
      @tunnel.instance_variable_get("@config")[:port].should eql(4445)
    end
  end
end