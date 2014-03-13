require 'spec_helper'

describe 'omnibus::_packaging' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'debian', version: '7.4')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('dpkg-dev')
      expect(chef_run).to install_package('ncurses-dev')
      expect(chef_run).to install_package('zlib1g-dev')
    end
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'freebsd', version: '9.1')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('ncurses')
    end
  end

  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'redhat', version: '6.5')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('rpm-build')
      expect(chef_run).to install_package('ncurses-devel')
      expect(chef_run).to install_package('zlib-devel')
    end
  end
end
