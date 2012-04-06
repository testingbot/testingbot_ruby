# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "testingbot/version"

Gem::Specification.new do |s|
  s.name        = "testingbot"
  s.version     = Testingbot::VERSION
  s.authors     = ["Jochen"]
  s.email       = ["info@testingbot.com"]
  s.homepage    = "http://www.testingbot.com"
  s.summary     = "Ruby Gem to be used with testingbot.com"
  s.description = "This gem makes using our Selenium grid on testingbot.com easy"

  s.rubyforge_project = "testingbot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "json"
end