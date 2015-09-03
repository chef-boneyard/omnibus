require 'spec_helper'

describe 'omnibus::_bash' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  it 'includes _compile' do
    expect(chef_run).to include_recipe('omnibus::_compile')
  end

  it 'remote_installs bash' do
    allow_any_instance_of(Chef::Resource).to receive(:installed_at_version?)

    expect(chef_run).to install_remote_install('bash')
      .with_source('http://ftp.gnu.org/gnu/bash/bash-4.3.30.tar.gz')
      .with_version('4.3.30')
      .with_checksum('317881019bbf2262fb814b7dd8e40632d13c3608d2f237800a8828fbb8a640dd')
      .with_build_command('./configure')
      .with_compile_command('make -j 2')
      .with_install_command('make install')
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
end
