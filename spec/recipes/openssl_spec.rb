require 'spec_helper'

describe 'omnibus::_openssl' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'on platforms that do not use omnibus toolchain' do
    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:omnibus_toolchain_enabled?).and_return(false)
    end

    context 'on suse' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'suse', version: '11.2')
          .converge(described_recipe)
      end

      it 'installs the correct development packages' do
        expect(chef_run).to install_package('zlib-devel')
        expect(chef_run).to install_package('libopenssl-devel')
      end
    end
  end
end
