# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "testingbot/version"

Gem::Specification.new do |gem|
  gem.name        = "testingbot"
  gem.version     = Testingbot::VERSION
  gem.authors     = ["Jochen Delabie"]
  gem.email       = ["info@testingbot.com"]
  gem.homepage    = "https://testingbot.com"
  gem.summary     = "Ruby API Gem to be used with testingbot.com"
  gem.description = "This gem makes interacting with the TestingBot API easy with Ruby"
  gem.metadata = {
  "bug_tracker_uri"   => "https://github.com/testingbot/testingbot_ruby/issues",
  "documentation_uri" => "https://github.com/testingbot/testingbot_ruby",
  "homepage_uri"      => "https://github.com/testingbot/testingbot_ruby",
  "source_code_uri"   => "https://github.com/testingbot/testingbot_ruby"
}
  gem.rubyforge_project = "testingbot"

  gem.files         = `git ls-files`.split($/).reject { |e| /spec/.match e }
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.license = 'MIT'
  
  gem.required_ruby_version = '~> 2.0'
  gem.add_runtime_dependency 'rest-client', '~> 2.0'
  gem.add_runtime_dependency 'json'
  gem.add_development_dependency "rspec", '~> 3.3'
  gem.add_development_dependency "rake"
end