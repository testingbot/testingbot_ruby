require 'rspec'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Testingbot Tunnel" do
  after :each do
    @tunnel.stop if @tunnel.is_connected?
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