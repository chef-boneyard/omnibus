require 'spec_helper'

describe 'omnibus::_packaging' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'debian', version: '7.4')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      %w(devscripts dpkg-dev fakeroot ncurses-dev zlib1g-dev).each do |pkg|
        expect(chef_run).to install_package(pkg)
      end
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

  shared_examples 'on rhel' do
    it 'installs the correct development packages' do
      %w(fakeroot rpm-build ncurses-devel zlib-devel).each do |pkg|
        expect(chef_run).to install_package(pkg)
      end
    end
  end

  context 'on rhel 6.5' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5')
        .converge(described_recipe)
    end

    it_behaves_like 'on rhel'

    it 'should not enable epel' do
      expect(chef_run).to_not include_recipe('yum-epel')
    end

    it 'should not install rpm-sign' do
      expect(chef_run).to_not install_package('rpm-sign')
    end
  end

  context 'on rhel 7.0' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '7.0')
        .converge(described_recipe)
    end

    it_behaves_like 'on rhel'

    it 'should enable epel' do
      expect(chef_run).to include_recipe('yum-epel')
    end

    it 'should install rpm-sign' do
      expect(chef_run).to install_package('rpm-sign')
    end
  end
end
