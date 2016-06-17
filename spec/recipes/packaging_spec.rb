require 'spec_helper'

describe 'omnibus::_packaging' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'debian', version: '7.4')
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
      ChefSpec::SoloRunner.new(platform: 'freebsd', version: '9.1')
                          .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('devel/ncurses')
    end
  end

  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'redhat', version: '6.5')
                          .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('rpm-build')
      expect(chef_run).to install_package('ncurses-devel')
      expect(chef_run).to install_package('zlib-devel')
    end
  end

  context "on centos" do
    shared_examples "installs from package repos" do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: centos_version)
                            .converge(described_recipe)
      end

      it "installs from the package repos" do
        expect(chef_run).to include_recipe("omnibus::_fakeroot_package")
      end
    end

    context "on centos 6" do
      let(:centos_version) { '6.6' }
      it_behaves_like "installs from package repos"
    end

    context "on centos 7" do
      let(:centos_version) { '7.0' }
      it_behaves_like "installs from package repos"

      context "on ppc" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0') do |node|
            node.automatic['kernel']['machine'] = 'ppc64'
          end.converge(described_recipe)
        end

        it "installs fakeroot from source" do
          expect(chef_run).to include_recipe("omnibus::_fakeroot_source")
        end
      end
    end
  end
end
