require 'bundler/setup'

namespace :style do
  require 'rubocop/rake_task'
  desc 'Run Ruby style checks'
  Rubocop::RakeTask.new(:ruby) do |t|
    t.options = ['--lint']
  end
end

desc 'Run all style checks'
task style: ['style:ruby']

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:unit)

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
  task ci: ['style', 'unit']
end

# The default rake task should just run it all
task default: ['travis:ci', 'integration']
