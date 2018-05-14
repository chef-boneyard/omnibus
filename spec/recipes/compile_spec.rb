require 'spec_helper'

describe 'omnibus::_compile' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'includes build-esssential' do
    expect(chef_run).to install_build_essential('install compilation tools')
  end

  context 'on macOS' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'mac_os_x',
        version: '10.12'
      ).converge(described_recipe)
    end

    # Keep the resources from an included recipe from being loaded into the Chef run,
    # but test that the recipe was included. Note, I attempted to scope the receive
    # message to just 'homebrew::default' and other recipes within the cookbook,
    # but it resulted in odd behavior which I could not easily resolve.
    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe)
    end

    it 'includes the homebrew cookbook' do
      expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('homebrew::default')
      chef_run
    end
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'freebsd', version: '11.1')
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
      ChefSpec::SoloRunner.new(platform: 'centos', version: '6.9').converge(described_recipe)
    end

    it 'installs tar and bzip2' do
      expect(chef_run).to install_package(%w(tar bzip2))
    end
  end

  context 'on Windows' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2')
                          .converge(described_recipe)
    end

    it 'includes seven_zip' do
      expect(chef_run).to include_recipe('seven_zip::default')
    end
  end
end
