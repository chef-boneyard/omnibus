require 'spec_helper'

describe 'omnibus::_rsync' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  it 'includes _compile' do
    expect(chef_run).to include_recipe('omnibus::_compile')
  end

  it 'remote_installs rsync' do
    allow_any_instance_of(Chef::Resource).to receive(:installed_at_version?)

    expect(chef_run).to install_remote_install('rsync')
      .with_source('http://rsync.samba.org/ftp/rsync/src/rsync-3.1.0.tar.gz')
      .with_version('3.1.0')
      .with_checksum('81ca23f77fc9b957eb9845a6024f41af0ff0c619b7f38576887c63fa38e2394e')
      .with_build_command('./configure')
      .with_compile_command('make -j 2')
      .with_install_command('make install')
  end

  it 'links /bin/rsync to our rsync' do
    expect(chef_run).to create_link('/bin/rsync')
      .with_to('/usr/local/bin/rsync')
  end
end
