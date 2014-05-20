require 'spec_helper'

describe 'omnibus::_ccache' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes chef-sugar' do
    expect(chef_run).to include_recipe('chef-sugar::default')
  end

  it 'includes _bash' do
    expect(chef_run).to include_recipe('omnibus::_common')
  end

  it 'includes _common' do
    expect(chef_run).to include_recipe('omnibus::_common')
  end

  it 'includes _compile' do
    expect(chef_run).to include_recipe('omnibus::_compile')
  end

  it 'remote_installs ccache' do
    expect(chef_run).to install_remote_install('ccache')
      .with_source('http://samba.org/ftp/ccache/ccache-3.1.9.tar.gz')
      .with_version('3.1.9')
      .with_checksum('a2270654537e4b736e437975e0cb99871de0975164a509dee34cf91e36eeb447')
      .with_build_command('./configure')
      .with_compile_command('make')
      .with_install_command('make install')
  end

  it 'links /usr/local/bin/gcc to ccache' do
    expect(chef_run).to create_link('/usr/local/bin/gcc')
      .with_to('/usr/local/bin/ccache')
  end

  it 'links /usr/local/bin/gcc to ccache' do
    expect(chef_run).to create_link('/usr/local/bin/gcc')
      .with_to('/usr/local/bin/ccache')
  end

  it 'links /usr/local/bin/g++ to ccache' do
    expect(chef_run).to create_link('/usr/local/bin/g++')
      .with_to('/usr/local/bin/ccache')
  end

  it 'links /usr/local/bin/cc to ccache' do
    expect(chef_run).to create_link('/usr/local/bin/cc')
      .with_to('/usr/local/bin/ccache')
  end

  it 'links /usr/local/bin/c++ to ccache' do
    expect(chef_run).to create_link('/usr/local/bin/c++')
      .with_to('/usr/local/bin/ccache')
  end
end
