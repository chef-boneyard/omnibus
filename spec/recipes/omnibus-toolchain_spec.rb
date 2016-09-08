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

    context 'when version has an override' do
      before do
        chef_run.node.normal['omnibus']['toolchain_version'] = '1.1.0-30499'
        chef_run.converge(described_recipe)
      end

      it 'installs a specific version of omnibus-toolchain' do
        expect(chef_run).to upgrade_chef_ingredient('omnibus-toolchain').with version: '1.1.0-30499'
      end
    end

    context 'when channel has an override' do
      before do
        chef_run.node.normal['omnibus']['toolchain_channel'] = 'unstable'
        chef_run.converge(described_recipe)
      end

      it 'installs omnibus-toolchain from a specific channel' do
        expect(chef_run).to upgrade_chef_ingredient('omnibus-toolchain').with channel: :unstable
      end
    end
  end
end
