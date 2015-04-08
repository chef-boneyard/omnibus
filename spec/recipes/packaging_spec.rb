require 'spec_helper'

describe 'omnibus::_packaging' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'debian', version: '7.4')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('devscripts')
      expect(chef_run).to install_package('dpkg-dev')
      expect(chef_run).to install_package('fakeroot')
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
      expect(chef_run).to install_package('devel/ncurses')
    end
  end

  context 'on rhel 6.5' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('fakeroot')
      expect(chef_run).to install_package('rpm-build')
      expect(chef_run).to install_package('ncurses-devel')
      expect(chef_run).to install_package('zlib-devel')
    end

    it 'should not enable epel' do
      expect(chef_run).to_not include_recipe('yum-epel')
    end
  end

  context 'on rhel 7.1' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.1')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('fakeroot')
      expect(chef_run).to install_package('rpm-build')
      expect(chef_run).to install_package('ncurses-devel')
      expect(chef_run).to install_package('zlib-devel')
    end

    it 'should enable epel' do
      expect(chef_run).to include_recipe('yum-epel')
    end
  end
end
