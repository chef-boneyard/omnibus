require 'spec_helper'

describe 'omnibus::_user' do
  cached(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  it 'creates the omnibus build user' do
    expect(chef_run).to create_user('omnibus')
      .with_shell(%r{(\/opt\/.*?\/bin\/bash|\/usr\/local\/bin\/bash)})
  end

  it 'creates the home directory' do
    expect(chef_run).to create_directory('/home/omnibus')
      .with_owner('omnibus')
      .with_mode('0755')
  end
end
