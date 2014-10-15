require 'spec_helper'

describe 'omnibus::_compile' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  it 'includes build-esssential' do
    expect(chef_run).to include_recipe('build-essential::default')
  end

  it 'includes homebrew on OSX' do
    stub_command('which git')
    osx_chef_run = ChefSpec::ServerRunner.new(platform: 'mac_os_x', version: '10.8.2')
                     .converge(described_recipe)
    expect(osx_chef_run).to include_recipe('homebrew::default')
  end
end
