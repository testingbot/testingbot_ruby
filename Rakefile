require "bundler/gem_tasks"
require "rspec/core/rake_task"

# Offline, mocked unit suite — the default and CI gate. Needs no credentials.
RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = "spec/unit/**/*_spec.rb"
end

# Live integration suite — hits the real API; requires TB_KEY / TB_SECRET.
RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = "spec/integration/**/*_spec.rb"
  t.rspec_opts = "--tag integration"
end

# `rake spec` and the default task run only the offline unit suite.
task :spec => :unit
task :default => :unit
