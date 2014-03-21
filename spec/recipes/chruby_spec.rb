require 'spec_helper'

describe 'omnibus::_chruby' do
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

  it 'installs chruby' do
    Chef::Resource.any_instance.stub(:installed_at_version?)

    expect(chef_run).to install_remote_install('chruby')
      .with_source('https://codeload.github.com/postmodern/chruby/tar.gz/v0.3.8')
      .with_checksum('d980872cf2cd047bc9dba78c4b72684c046e246c0fca5ea6509cae7b1ada63be')
      .with_version('0.3.8')
      .with_install_command('make install')
  end

  it 'creates an /etc/profile.d entry' do
    expect(chef_run).to create_file('/etc/profile.d/chruby.sh')
      .with_mode('0755')
  end
end
