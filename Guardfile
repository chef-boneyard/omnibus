guard :rspec, cmd: "bundle exec rspec", :all_on_start => false do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  watch(%r{^spec/recipes/(.+)_specs\.rb$})
  watch(%r{^recipes/_(.+)\.rb$})   { |m| "spec/recipes/#{m[1]}_spec.rb" }
  watch(%r{^libraries/(.+)\.rb$}) { "spec/recipes/*_spec.rb" }
  watch('spec/spec_helper.rb')      { 'spec' }
end


