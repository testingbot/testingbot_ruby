require 'rspec'
require 'capybara/rspec'
require 'testingbot'
require 'testingbot/capybara'

browsers = [{ :browserName => "firefox", :version => 9, :platform => "WINDOWS" }, { :browserName => "firefox", :version => 10, :platform => "WINDOWS" }]

browsers.each do |browser|

	shared_examples "an example test on #{browser[:browserName]} #{browser[:version]}" do |actions|
	  	describe "Demo", :type => :request do
			before :all do
				TestingBot::config do |config|
					config[:desired_capabilities] = browser
				end
				Capybara.run_server = false 
				Capybara.current_driver = :testingbot
			    Capybara.app_host = "http://testingbot.com"
		 	end

		 	after :all do
		 		TestingBot::reset_config!
		 		Capybara.current_driver = :testingbot
		 		page.driver.browser.quit
    			page.driver.instance_variable_set(:@browser, nil)
		 	end

			it 'has a homepage with the word Selenium' do
				visit '/'
				page.should have_content('Selenium')
			end
		end
	end

	describe "Sample", :type => :request do
		it_behaves_like "an example test on #{browser[:browserName]} #{browser[:version]}"
	end
end