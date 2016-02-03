require 'spec_helper'

describe 'omnibus::_git' do
  context 'on all platforms' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'writes a sane git config' do
      expect(chef_run).to create_file('/home/omnibus/.gitconfig')
        .with_owner('omnibus')
        .with_mode('0644')
    end
  end

  context 'on platforms that do not use omnibus toolchain' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:omnibus_toolchain_enabled?).and_return(false)
    end

    it 'includes _bash' do
      expect(chef_run).to include_recipe('omnibus::_bash')
    end

    it 'includes _compile' do
      expect(chef_run).to include_recipe('omnibus::_compile')
    end

    it 'includes _openssl' do
      expect(chef_run).to include_recipe('omnibus::_openssl')
    end

    context 'on suse 11' do
      let(:chef_run) do
        ChefSpec::SoloRunner.new(platform: 'suse', version: '11.2')
          .converge(described_recipe)
      end

      it 'installs the correct development packages' do
        expect(chef_run).to install_package('libcurl-devel')
        expect(chef_run).to install_package('libexpat-devel')
        expect(chef_run).to install_package('gettext-runtime')
        expect(chef_run).to install_package('zlib-devel')
      end
    end

    it 'installs git' do
      allow_any_instance_of(Chef::Resource).to receive(:installed_at_version?).and_return(false)

      expect(chef_run).to install_remote_install('git')
        .with_source('https://www.kernel.org/pub/software/scm/git/git-2.6.2.tar.gz')
        .with_checksum('34dfc06b44880df91940dc318a2d3c83b79e67b6f05319c7c71e94d30893636d')
        .with_version('2.6.2')
        .with_build_command('./configure --prefix=/usr/local --without-tcltk')
        .with_compile_command('make -j 2')
        .with_install_command('make install')
    end
  end

  context 'on platforms that use omnibus toolchain' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:omnibus_toolchain_enabled?).and_return(true)
    end

    it "properly configures git's cacert" do
      expect(chef_run).to run_execute('git config --global http.sslCAinfo /opt/omnibus-toolchain/embedded/ssl/certs/cacert.pem')
        .with_user('omnibus')
    end
  end
end
