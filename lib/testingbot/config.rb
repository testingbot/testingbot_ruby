module TestingBot
  @@config = nil
  def self.get_config
    @@config = TestingBot::Config.new if @@config.nil?
    @@config
  end

  def self.reset_config!
    @@config = nil
  end

  def self.config
    yield self.get_config
  end
  
  class Config
    
    attr_reader :options
    
    def initialize(options = {})
      @options = default_options
      @options = @options.merge(load_config_file)
      @options = @options.merge(load_config_environment)
      @options = @options.merge(options)
    end
    
    def [](key)
      @options[key]
    end

    def add_options(options = {})
      @options = @options.merge(options)
    end

    def []=(key, value)
      @options[key] = value
    end

    def require_tunnel(host = "127.0.0.1", port = 4445)
      @options[:require_tunnel] = true
      @options[:host] = host
      @options[:port] = port
    end
    
    def client_key
      @options[:client_key]
    end
    
    def client_secret
      @options[:client_secret]
    end

    def desired_capabilities
      @options[:desired_capabilities]
    end
    
    private

    def default_options
      {
        :host => "hub.testingbot.com",
        :port => 4444
      }
    end
    
    def load_config_file
      options = {}
      
      is_windows = (RUBY_PLATFORM =~ /w.*32/)
      
      if is_windows
        config_file = "#{ENV['HOMEDRIVE']}\\.testingbot"
      else
        config_file = File.expand_path("~/.testingbot")
      end
      
      if File.exists?(config_file)
        str = File.open(config_file) { |f| f.readline }.chomp
        options[:client_key], options[:client_secret] = str.split(':')
      end
      
      options
    end
    
    def load_config_environment
      options = {}
      options[:client_key] = ENV['TESTINGBOT_CLIENTKEY']
      options[:client_secret] = ENV['TESTINGBOT_CLIENTSECRET']
      
      options.delete_if { |key, value| value.nil?}
      
      options
    end
  end
end