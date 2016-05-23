require 'spec_helper'

describe 'omnibus::_compile' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'includes build-esssential' do
    expect(chef_run).to include_recipe('build-essential::default')
  end

  it 'includes homebrew on OSX' do
    stub_command('which git')
    osx_chef_run = ChefSpec::SoloRunner.new(platform: 'mac_os_x', version: '10.8.2')
                                       .converge(described_recipe)
    expect(osx_chef_run).to include_recipe('homebrew::default')
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'freebsd', version: '10.0')
                          .converge(described_recipe)
    end

    it 'Configures BSD Make for backward compat mode' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/etc/make.conf').and_return(true)
      expect(chef_run).to run_ruby_block('Configure BSD Make for backward compat mode')
    end
  end

  context 'on Solaris 10' do
    let(:chef_run) do
      # Make Solaris 11 look like Solaris 10 as Fauxhai doesn't yet contain
      # data for the latter.
      ChefSpec::SoloRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.automatic['platform_version'] = '5.10'
      end.converge(described_recipe)
    end

    it 'creates a `make` symlink that points to `gmake`' do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/usr/sfw/bin/gmake').and_return(true)
      expect(chef_run).to create_link('/usr/local/bin/make')
        .with_to('/usr/sfw/bin/gmake')
    end
  end

  context 'on RHEL' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6').converge(described_recipe)
    end

    it 'installs tar' do
      expect(chef_run).to install_package('tar')
    end

    it 'installs bzip2' do
      expect(chef_run).to install_package('bzip2')
    end
  end

  context 'on Windows' do
    let(:node_name) { 'chefdk-windows-2008r2-builder-1a6dad' }
    let(:platform_version) { '2008R2' }

    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: platform_version) do |node|
        node.name(node_name)
        node.automatic['fqdn'] = node_name
      end.converge(described_recipe)
    end

    let(:omnibus_env_path) { chef_run.node.run_state[:omnibus_env]['PATH'] }
    let(:omnibus_msystem) { chef_run.node.run_state[:omnibus_env]['MSYSTEM'] }

    it 'prefers the 64-bit MinGW toolchain' do
      expect(omnibus_env_path).to include('C:\msys2\bin', 'C:\msys2\mingw64\bin')
      expect(omnibus_msystem).to eq(['MINGW64'])
    end

    context 'when a Windows node has a 32-bit architecture' do
      # This version of Windows has a 32-bit arch in Fauxhai:
      #
      #   https://github.com/customink/fauxhai/blob/master/lib/fauxhai/platforms/windows/2003R2.json#L186
      #
      let(:platform_version) { '2003R2' }

      it 'prefers the 32-bit MinGW toolchain' do
        expect(omnibus_env_path).to include('C:\msys2\bin', 'C:\msys2\mingw32\bin')
        expect(omnibus_msystem).to eq(['MINGW32'])
      end
    end

    context 'when a Windows node has i386 in its name' do
      let(:node_name) { 'chefdk-windows-2008r2-i386-builder-dcb6f4' }

      it 'prefers the 32-bit MinGW toolchain' do
        expect(omnibus_env_path).to include('C:\msys2\bin', 'C:\msys2\mingw32\bin')
        expect(omnibus_msystem).to eq(['MINGW32'])
      end
    end
  end
end
