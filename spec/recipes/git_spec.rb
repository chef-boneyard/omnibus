require 'spec_helper'

describe 'omnibus::_git' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  it 'includes _bash' do
    expect(chef_run).to include_recipe('omnibus::_bash')
  end

  it 'includes _compile' do
    expect(chef_run).to include_recipe('omnibus::_compile')
  end

  it 'includes _openssl' do
    expect(chef_run).to include_recipe('omnibus::_openssl')
  end

  context 'on debian' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'debian', version: '7.4')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('gettext')
      expect(chef_run).to install_package('libcurl4-gnutls-dev')
      expect(chef_run).to install_package('libexpat1-dev')
      expect(chef_run).to install_package('libz-dev')
      expect(chef_run).to install_package('perl-modules')
    end
  end

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'freebsd', version: '9.1')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('ftp/curl')
      expect(chef_run).to install_package('textproc/expat2')
      expect(chef_run).to install_package('devel/gettext')
      expect(chef_run).to install_package('archivers/libzip')
    end

    it 'uses GNU Make' do
      allow_any_instance_of(Chef::Resource).to receive(:installed_at_version?).and_return(false)

      expect(chef_run).to install_remote_install('git')
        .with_compile_command('gmake -j 2')
        .with_install_command('gmake install')
    end
  end

  context 'on mac_os_x' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'mac_os_x', version: '10.8.2')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      stub_command('which git')

      expect(chef_run).to install_package('curl')
      expect(chef_run).to install_package('expat')
      expect(chef_run).to install_package('gettext')
    end
  end

  context 'on Solaris 10' do
    let(:chef_run) do
      # Make Solaris 11 look like Solaris 10 as Fauxhai doesn't yet contain
      # data for the latter.
      ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.automatic['platform_version'] = '5.10'
      end.converge(described_recipe)
    end

    it "properly configures git's cacert" do
      expect(chef_run).to run_execute('git config --global http.sslCAinfo /opt/omnibus-toolchain/embedded/ssl/certs/cacert.pem')
        .with_user('omnibus')
    end
  end

  context 'on rhel 5' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '5.10')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('curl-devel')
      expect(chef_run).to install_package('expat-devel')
      expect(chef_run).to install_package('gettext-devel')
      expect(chef_run).to install_package('zlib-devel')
    end
  end

  context 'on rhel 6' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5')
        .converge(described_recipe)
    end

    it 'installs the correct development packages' do
      expect(chef_run).to install_package('curl-devel')
      expect(chef_run).to install_package('expat-devel')
      expect(chef_run).to install_package('gettext-devel')
      expect(chef_run).to install_package('perl-ExtUtils-MakeMaker')
      expect(chef_run).to install_package('zlib-devel')
    end
  end

  context 'on suse 11' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'suse', version: '11.2')
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
      .with_source('https://git-core.googlecode.com/files/git-1.9.0.tar.gz')
      .with_checksum('de3097fdc36d624ea6cf4bb853402fde781acdb860f12152c5eb879777389882')
      .with_version('1.9.0')
      .with_build_command('./configure --prefix=/usr/local --without-tcltk')
      .with_compile_command('make -j 2')
      .with_install_command('make install')
  end

  it 'writes a sane git config' do
    expect(chef_run).to create_file('/home/omnibus/.gitconfig')
      .with_owner('omnibus')
      .with_mode('0644')
  end
end
