require 'spec_helper'

describe 'omnibus::_xml' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'debian', version: '7.4')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('libxml2-dev')
      expect(chef_run).to install_package('libxslt-dev')
      expect(chef_run).to install_package('ncurses-dev')
      expect(chef_run).to install_package('zlib1g-dev')
    end
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'freebsd', version: '9.1')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('textproc/libxml2')
      expect(chef_run).to install_package('textproc/libxslt')
      expect(chef_run).to install_package('devel/ncurses')
    end
  end

  context 'on mac_os_x' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'mac_os_x', version: '10.8.2')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('libxml2')
      expect(chef_run).to install_package('libxslt')
    end
  end

  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('libxml2-devel')
      expect(chef_run).to install_package('libxslt-devel')
      expect(chef_run).to install_package('ncurses-devel')
      expect(chef_run).to install_package('zlib-devel')
    end
  end
end
