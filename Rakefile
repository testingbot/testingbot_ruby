require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'

task :spec do
  begin
    require 'rspec/core/rake_task'
    desc "Run the specs under spec/"
    RSpec::Core::RakeTask.new do |t|
    	t.fail_on_error = false
	    t.pattern = FileList['spec/**/*_spec.rb'].exclude(/tunnel/)
    end
  rescue NameError, LoadError => e
    puts e
  end
end