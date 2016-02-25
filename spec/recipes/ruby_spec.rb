require 'spec_helper'

describe 'omnibus::_ruby' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'on platforms that do not use omnibus toolchain' do
    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:omnibus_toolchain_enabled?).and_return(false)
    end

    # Not sure what to put here, there isn't really much to test?

  end
end
