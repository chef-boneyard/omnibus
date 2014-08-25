require 'spec_helper'

describe 'omnibus::_common' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes _user' do
    expect(chef_run).to include_recipe('omnibus::_user')
  end

  it 'includes chef-sugar::default' do
    expect(chef_run).to include_recipe('chef-sugar::default')
  end

  it 'creates the file cache path' do
    expect(chef_run).to create_directory(Chef::Config[:file_cache_path])
      .with_recursive(true)
  end

  it 'creates the install dir' do
    expect(chef_run).to create_directory('/opt/omnibus')
      .with_mode('0755')
      .with_owner('omnibus')
      .with_recursive(true)
  end

  it 'creates the cache dir' do
    expect(chef_run).to create_directory('/var/cache/omnibus')
      .with_mode('0755')
      .with_owner('omnibus')
      .with_recursive(true)
  end

  context 'on RHEL' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'redhat', version: '5.10')
        .converge(described_recipe)
    end

    it 'includes yum-epel' do
      expect(chef_run).to include_recipe('yum-epel::default')
    end
  end
end
