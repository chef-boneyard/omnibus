require 'spec_helper'

describe 'omnibus::_git' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes _bash' do
    expect(chef_run).to include_recipe('omnibus::_bash')
  end

  it 'includes _common' do
    expect(chef_run).to include_recipe('omnibus::_common')
  end

  it 'includes _compile' do
    expect(chef_run).to include_recipe('omnibus::_compile')
  end

  it 'includes _openssl' do
    expect(chef_run).to include_recipe('omnibus::_openssl')
  end

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'debian', version: '7.4')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('libcurl4-gnutls-dev')
      expect(chef_run).to install_package('libexpat1-dev')
      expect(chef_run).to install_package('gettext')
      expect(chef_run).to install_package('libz-dev')
      expect(chef_run).to install_package('perl-modules')
    end
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'freebsd', version: '9.1')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      stub_command('perl -v | grep "perl 5"').and_return(false)

      expect(chef_run).to install_package('curl')
      expect(chef_run).to install_package('expat2')
      expect(chef_run).to install_package('gettext')
      expect(chef_run).to install_package('libzip')
      expect(chef_run).to install_package('perl5')
        .with_source('ports')
    end
  end

  context 'on mac_os_x' do
    pending
    # let(:chef_run) do
    #   ChefSpec::Runner.new(platform: 'mac_os_x', version: '10.8.2')
    #     .converge(described_recipe)
    # end

    # it 'installs the correct development packages' do
    #   expect(chef_run).to install_package('curl')
    #   expect(chef_run).to install_package('expat')
    #   expect(chef_run).to install_package('gettext')
    # end
  end

  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'redhat', version: '6.5')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('curl-devel')
      expect(chef_run).to install_package('expat-devel')
      expect(chef_run).to install_package('gettext-devel')
      expect(chef_run).to install_package('perl-ExtUtils-MakeMaker')
      expect(chef_run).to install_package('zlib-devel')
    end
  end

  it 'installs git' do
    Chef::Resource.any_instance.stub(:installed_at_version?).and_return(false)

    expect(chef_run).to install_remote_install('git')
      .with_source('https://github.com/git/git/archive/v1.9.0.tar.gz')
      .with_checksum('064f2ee279cc05f92f0df79c1ca768771393bc3134c0fa53b17577679383f039')
      .with_version('1.9.0')
      .with_build_command('make prefix=/usr/local all')
      .with_install_command('make prefix=/usr/local install')
  end
end
