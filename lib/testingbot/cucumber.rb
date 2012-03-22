require 'testingbot/config'

if defined?(Cucumber)
	After do |scenario|
    client_key = TestingBot.get_config[:client_key]
    client_secret = TestingBot.get_config[:client_secret]
    
	  if Capybara.drivers.include?(:testingbot) && !TestingBot.get_config[:client_key].nil?
	    begin
        session_id = page.driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
          
        params = {
            "session_id" => session_id,
            "client_key" => client_key,
            "client_secret" => client_secret,
            "status_message" => (scenario.failed? ? scenario.exception.message : ""),
            "success" => !scenario.failed?,
            "name" => scenario.title,
            "kind" => 2
        }
        
        url = URI.parse('http://testingbot.com/hq')
        http = Net::HTTP.new(url.host, url.port)
        response = http.post(url.path, params.map { |k, v| "#{k.to_s}=#{v}" }.join("&"))
      rescue Exception => e
        p "Could not determine sessionID, can not send results to TestingBot.com #{e.message}"
      end
	  end
	end
end