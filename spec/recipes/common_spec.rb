require 'spec_helper'

describe 'omnibus::_common' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

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

  it 'creates the Omnibus base dir' do
    expect(chef_run).to create_directory('/var/cache/omnibus')
      .with_mode('0755')
      .with_owner('omnibus')
      .with_recursive(true)
  end

  context '`install_dir` attribute is set' do
    let(:install_dir) { '/opt/foo' }
    let(:chef_run) do
      ChefSpec::SoloRunner.new do |node|
        node.override['omnibus']['install_dir'] = install_dir
      end.converge(described_recipe)
    end

    it 'creates the install dir' do
      expect(chef_run).to create_directory(install_dir)
        .with_mode('0755')
        .with_owner('omnibus')
        .with_recursive(true)
    end
  end
end
