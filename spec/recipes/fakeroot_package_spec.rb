require 'spec_helper'

describe 'omnibus::_fakeroot_package' do
  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5')
                          .converge(described_recipe)
    end

    it 'does not enable EPEL' do
      expect(chef_run).to_not create_yum_repository('epel')
    end

    it 'installs fakeroot' do
      expect(chef_run).to install_package('fakeroot')
    end
  end

  context 'on centos' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.5')
                          .converge(described_recipe)
    end

    it 'enables the EPEL repo' do
      expect(chef_run).to create_yum_repository('epel')
    end

    it 'installs fakeroot' do
      expect(chef_run).to install_package('fakeroot')
    end
  end
end
