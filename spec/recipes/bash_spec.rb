require 'spec_helper'

describe 'omnibus::_bash' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes _common' do
    expect(chef_run).to include_recipe('omnibus::_common')
  end

  it 'includes _compile' do
    expect(chef_run).to include_recipe('omnibus::_compile')
  end

  it 'remote_installs bash' do
    Chef::Resource.any_instance.stub(:installed_at_version?)

    expect(chef_run).to install_remote_install('bash')
      .with_source('http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz')
      .with_version('4.3')
      .with_checksum('afc687a28e0e24dc21b988fa159ff9dbcf6b7caa92ade8645cc6d5605cd024d4')
      .with_build_command('./configure')
      .with_compile_command('make')
      .with_install_command('make install')
  end

  it 'links /bin/bash to our bash' do
    expect(chef_run).to create_link('/bin/bash')
      .with_to('/usr/local/bin/bash')
  end
end
