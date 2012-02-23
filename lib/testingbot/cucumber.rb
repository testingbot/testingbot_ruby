if defined?(Cucumber)
	After do |scenario|
	  if Capybara.drivers.include?(:testingbot) && File.exists?(File.expand_path("~/.testingbot"))
	  	unless Capybara.drivers[:testingbot].call.browser.nil?
	  		session_id = Capybara.drivers[:testingbot].call.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")

			str = File.open(File.expand_path("~/.testingbot")) { |f| f.readline }.chomp
		    client_key, client_secret = str.split(':')
		    
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
	  	end
	  end
	end
end