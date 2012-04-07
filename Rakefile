require "bundler/gem_tasks"
require 'rake'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
	t.libs << "lib"
	t.test_files = FileList["spec/integration/*_spec.rb", "spec/unit/*_spec.rb"]
	t.verbose = true
end