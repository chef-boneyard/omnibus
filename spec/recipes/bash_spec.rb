require 'spec_helper'

describe 'omnibus::_bash' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes _compile' do
    expect(chef_run).to include_recipe('omnibus::_compile')
  end

  it 'remote_installs bash' do
    allow_any_instance_of(Chef::Resource).to receive(:installed_at_version?)

    expect(chef_run).to install_remote_install('bash')
      .with_source('http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz')
      .with_version('4.3')
      .with_checksum('afc687a28e0e24dc21b988fa159ff9dbcf6b7caa92ade8645cc6d5605cd024d4')
      .with_build_command('./configure')
      .with_compile_command('make --jobs=2')
      .with_install_command('make install')
  end

  it 'links /bin/bash to our bash' do
    expect(chef_run).to create_link('/bin/bash')
      .with_to('/usr/local/bin/bash')
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
