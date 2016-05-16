require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/sugar'

ChefSpec::Coverage.start!

# load all libraries for testing
Dir['libraries/*.rb'].each { |f| require_relative "../#{f}" }

RSpec.configure do |config|
  config.before(:each) do
    # We need to stub the build_user_home because ChefSpec isn't smart enough
    # to realize that a resource has already been touched once the attribute
    # changes. Global state is hard...
    allow_any_instance_of(Chef::Recipe).to receive(:build_user_home)
      .and_return('/home/omnibus')

    # Allow us to mimic a Windows node
    stub_const('File::ALT_SEPARATOR', '\\')
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('SYSTEMDRIVE').and_return('C:')
  end

  config.log_level = :fatal

  # Guard against people using deprecated RSpec syntax
  config.raise_errors_for_deprecations!

  # Why aren't these the defaults?
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Set a default platform (this is overriden as needed)
  config.platform  = 'ubuntu'
  config.version   = '12.04'

  # Be random!
  config.order = 'random'

  # this is essentially a copy of the omnibus_toolchain_enabled method in
  # Omnibus::Helper
  def omnibus_toolchain_enabled?
    # the only platforms we don't run the toolchain on yet is Windows
    !windows?
  end
end
