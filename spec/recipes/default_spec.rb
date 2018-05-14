require 'spec_helper'

describe 'omnibus::default' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'creates the Chef::Config[:file_cache_path] directory' do
    expect(chef_run).to create_directory(Chef::Config[:file_cache_path])
  end

  it 'creates the omnibus user' do
    expect(chef_run).to create_user('omnibus')
  end

  it 'creates the omnibus cache_dir' do
    expect(chef_run).to create_directory('/var/cache/omnibus').with(
      mode: '0755',
      user: 'omnibus'
    )
  end
end
