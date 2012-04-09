require 'testingbot/config'
require 'testingbot/capybara'
require 'testingbot/api'

if defined?(Cucumber)
    Before('@selenium') do
        ::Capybara.current_driver = :testingbot
    end

    After('@selenium') do |scenario|
        if !TestingBot.get_config[:client_key].nil?
            begin
                driver = ::Capybara.current_session.driver
                if driver.browser.respond_to?(:session_id)
                    session_id = driver.browser.session_id
                else
                    session_id = driver.browser.instance_variable_get("@bridge").instance_variable_get("@session_id")
                end

                api = TestingBot::Api.new
                params = {
                    "session_id" => session_id,
                    "status_message" => (scenario.failed? ? scenario.exception.message : ""),
                    "success" => !scenario.failed? ? 1 : 0,
                    "name" => scenario.title,
                    "kind" => 2
                }

                data = api.update_test(session_id, params)
            rescue Exception => e
                p "Could not determine sessionID, can not send results to TestingBot.com #{e.message}"
            end
        end
    end
end