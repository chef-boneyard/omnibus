require 'spec_helper'

describe 'omnibus::_ruby' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes _common' do
    expect(chef_run).to include_recipe('omnibus::_common')
  end

  context 'on windows' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'windows', version: '2008R2')
        .converge(described_recipe)
    end

    it 'includes _ruby_windows' do
      pending 'bugs in chefspec with windows testing'
    end
  end

  context 'on non-windows' do
    it 'includes _bash' do
      expect(chef_run).to include_recipe('omnibus::_bash')
    end

    it 'includes _compile' do
      expect(chef_run).to include_recipe('omnibus::_compile')
    end

    it 'includes _openssl' do
      expect(chef_run).to include_recipe('omnibus::_openssl')
    end

    it 'includes _xml' do
      expect(chef_run).to include_recipe('omnibus::_xml')
    end

    it 'includes _yaml' do
      expect(chef_run).to include_recipe('omnibus::_yaml')
    end

    it 'installs ruby-install' do
      Chef::Resource.any_instance.stub(:installed_at_version?)

      expect(chef_run).to install_remote_install('ruby-install')
        .with_source('https://codeload.github.com/postmodern/ruby-install/tar.gz/v0.4.1')
        .with_checksum('1b35d2b6dbc1e75f03fff4e8521cab72a51ad67e32afd135ddc4532f443b730e')
        .with_version('0.4.1')
        .with_install_command('make install')
    end

    it 'installs ruby' do
      expect(chef_run).to install_ruby_install('2.1.1')
    end

    it 'installs bundler' do
      expect(chef_run).to install_ruby_gem('bundler')
    end
  end
end
