require 'spec_helper'

describe 'omnibus::_user' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'creates the omnibus user' do
    expect(chef_run).to create_user('omnibus')
  end

  it 'creates the home directory' do
    expect(chef_run).to create_directory('/home/omnibus')
      .with_owner('omnibus')
      .with_mode('0755')
  end

  it 'creates the .bashrc.d' do
    expect(chef_run).to create_directory('/home/omnibus/.bashrc.d')
      .with_owner('omnibus')
      .with_mode('0755')
  end

  it 'creates the .bash_profile' do
    expect(chef_run).to create_file('/home/omnibus/.bash_profile')
  end

  it 'creates the .bashrc' do
    expect(chef_run).to create_file('/home/omnibus/.bashrc')
  end

  it 'creates the .omnibus-path' do
    expect(chef_run).to create_file('/home/omnibus/.bashrc.d/omnibus-path.sh')
      .with_owner('omnibus')
      .with_mode('0755')
  end

  it 'creates the .chruby-default' do
    expect(chef_run).to create_file('/home/omnibus/.bashrc.d/chruby-default.sh')
      .with_owner('omnibus')
      .with_mode('0755')
  end
end
