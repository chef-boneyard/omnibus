require 'bundler/setup'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:recipes) do |t|
  t.pattern = "spec/recipes/**/*_spec.rb"
  t.rspec_opts = [].tap do |a|
    a.push('--color')
    a.push('--format progress')
  end.join(' ')
end

require 'kitchen'
desc 'Run Test Kitchen integration tests'
task :integration do
  Kitchen.logger = Kitchen.default_file_logger
  Kitchen::Config.new.instances.each do |instance|
    instance.test(:always)
  end
end

# We cannot run Test Kitchen on Travis CI yet...
namespace :travis do
  desc 'Run tests on Travis'
  task ci: ['recipes']
end

# The default rake task should just run it all
task default: ['travis:ci', 'integration']
