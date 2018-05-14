require 'spec_helper'

describe 'omnibus::_packaging' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'debian', version: '8.10')
                          .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package(['devscripts', 'dpkg-dev', 'ncurses-dev', 'zlib1g-dev', 'fakeroot', 'binutils', 'gnupg'])
    end
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'freebsd', version: '11.1')
                          .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('devel/ncurses')
    end
  end

  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9')
                          .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package(['ncurses-devel', 'rpm-build', 'zlib-devel'])
    end
  end
end
