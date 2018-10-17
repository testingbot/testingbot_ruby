# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "testingbot/version"

Gem::Specification.new do |s|
  s.name        = "testingbot"
  s.version     = Testingbot::VERSION
  s.authors     = ["Jochen Delabie"]
  s.email       = ["info@testingbot.com"]
  s.homepage    = "https://testingbot.com"
  s.summary     = "Ruby API Gem to be used with testingbot.com"
  s.description = "This gem makes interacting with the TestingBot API easy with Ruby"

  s.rubyforge_project = "testingbot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "json"
  s.add_dependency "net-http-persistent"
  s.add_dependency "selenium-webdriver"
  s.add_development_dependency "rspec", [">= 2.9.0"]
  s.add_development_dependency "rake"
end