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

  context 'on RHEL' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6').converge(described_recipe)
    end

    it 'installs tar' do
      expect(chef_run).to install_package('tar')
    end
  end
end
