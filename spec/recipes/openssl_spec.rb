require 'spec_helper'

describe 'omnibus::_openssl' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'debian', version: '7.4')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('libssl-dev')
    end
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'freebsd', version: '9.1')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('openssl')
    end
  end

  context 'on mac_os_x' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'mac_os_x', version: '10.8.2')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('openssl')
    end
  end

  context 'on suse' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'suse', version: '11.2')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('zlib-devel')
      expect(chef_run).to install_package('libopenssl-devel')
    end
  end

  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('openssl-devel')
    end
  end
end
