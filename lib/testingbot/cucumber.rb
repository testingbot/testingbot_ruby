require 'testingbot/config'
require 'testingbot/capybara'

if defined?(Cucumber)
    Before('@selenium') do
        ::Capybara.current_driver = :testingbot
    end

    After('@selenium') do |scenario|
        if !TestingBot.get_config[:client_key].nil?
            begin
                driver = ::Capybara.current_session.driver
                session_id = driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
                  
                params = {
                    "session_id" => session_id,
                    "client_key" => TestingBot.get_config[:client_key],
                    "client_secret" => TestingBot.get_config[:client_secret],
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