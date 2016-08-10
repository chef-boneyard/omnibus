require 'spec_helper'

describe 'omnibus::_omnibus_toolchain' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'on platforms that use omnibus toolchain' do
    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:omnibus_toolchain_enabled?).and_return(true)
    end

    it 'installs omnibus-toolchain' do
      expect(chef_run).to upgrade_chef_ingredient('omnibus-toolchain')
    end
  end
end
