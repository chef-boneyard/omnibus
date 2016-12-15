require 'spec_helper'

describe 'On unix-ish', if: !windows? do
  describe 'platforms with omnibus toolchain enabled', if: omnibus_toolchain_enabled? do
    describe user(build_user) do
      it { should exist }
      it { should have_login_shell '/opt/omnibus-toolchain/bin/bash' }
    end

    describe 'Xcode Command Line Tools', if: mac_os_x? do
      let(:pkg_receipt) do
        if omnibus_platform_version(os[:family], os[:release]) == '10.8'
          'com.apple.pkg.DeveloperToolsCLI'
        else
          'com.apple.pkg.CLTools_Executables'
        end
      end

      it 'is installed' do
        expect(command("pkgutil --pkg-info=#{pkg_receipt}").exit_status).to eq 0
      end
    end

    describe 'ruby' do
      describe command('/opt/omnibus-toolchain/bin/ruby --version') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'bash --version' do
      describe command('/opt/omnibus-toolchain/bin/bash --version') do
        its(:exit_status) { should eq 0 }
      end
    end

    describe 'git --version' do
      describe command('/opt/omnibus-toolchain/bin/git --version') do
        its(:exit_status) { should eq 0 }
      end

      # Ensure `https` remote functions correctly
      Dir.mktmpdir('omnibus') do |tmpdir|
        # Ensure HTTPS remote support works
        describe command("/opt/omnibus-toolchain/bin/git clone https://github.com/chef-cookbooks/omnibus.git #{tmpdir}") do
          its(:exit_status) { should eq 0 }
        end
      end
    end

    describe file(File.join(build_user_home_dir, 'load-omnibus-toolchain.sh')) do
      it { should be_file }

      describe command("su - #{build_user} -l -c 'source ~/load-omnibus-toolchain.sh && which ruby'") do
        its(:stdout) { should match %r{/opt/omnibus-toolchain/bin/ruby$} }
      end
      describe command("su - #{build_user} -l -c 'source ~/load-omnibus-toolchain.sh && echo $PATH'") do
        its(:stdout) { should match %r{^/opt/omnibus-toolchain/bin(.+)} }
      end
    end
  end

  describe 'platforms without omnibus toolchain enabled', if: !omnibus_toolchain_enabled? do
    describe 'ruby' do
      describe command('/opt/languages/ruby/2.1.5/bin/ruby --version') do
        its(:stdout) { should match('2.1.5') }
      end
    end

    describe 'bash' do
      describe command('/usr/local/bin/bash --version') do
        its(:stdout) { should match('4.3.30') }
      end
    end

    describe 'git' do
      describe command('/usr/local/bin/git --version') do
        its(:stdout) { should match('2.6.2') }
      end

      # Ensure `https` remote functions correctly
      Dir.mktmpdir('omnibus') do |tmpdir|
        # Ensure HTTPS remote support works
        describe command("/usr/local/bin/git clone https://github.com/chef-cookbooks/omnibus.git #{tmpdir}") do
          its(:exit_status) { should eq 0 }
        end
      end
    end

    describe file(File.join(build_user_home_dir, 'load-omnibus-toolchain.sh')) do
      it { should be_file }

      describe command("su - #{build_user} -l -c 'source ~/load-omnibus-toolchain.sh && which ruby'") do
        its(:stdout) { should match %r{/opt/languages/ruby/2.1.5/bin/ruby$} }
      end
      describe command("su - #{build_user} -l -c 'source ~/load-omnibus-toolchain.sh && echo $PATH'") do
        its(:stdout) { should match %r{^/usr/local/bin(.+)} }
      end
    end
  end

  describe group(build_user), pending: mac_os_x? do
    it { should exist }
  end

  describe 'environment' do
    describe file(omnibus_base_dir) do
      it { should exist }
      it { should be_directory }
    end

    [
      '.gitconfig',
      'load-omnibus-toolchain.sh',
    ].each do |env_file|
      describe file(File.join(build_user_home_dir, env_file)) do
        it { should be_file }
        # it { should be_owned_by 'omnibus' }
        # it { should be_grouped_into 'omnibus' }
      end
    end

    describe file(File.join(build_user_home_dir, 'sign-rpm')), if: os[:family] == 'redhat' do
      it { should be_file }
      it { should be_owned_by(build_user) }
      it { should be_grouped_into(build_user) }
    end

    describe file('/etc/make.conf'), if: os[:family] == 'freebsd' do
      it { should be_file }
      its(:content) { should match(/\.MAKEFLAGS: -B/) }
    end

    describe file('/etc/ssl/cert.pem'), if: os[:family] == 'freebsd' do
      it { should be_symlink }
    end
  end
end

describe 'Windows', if: windows? do
  describe 'ruby' do
    describe command('C:/languages/ruby/2.1.5/bin/ruby --version') do
      its(:stdout) { should match '2.1.5' }
    end

    describe command('C:/languages/ruby/2.1.5/bin/bundle --version') do
      its(:exit_status) { should eq 0 }
    end
  end

  describe 'git' do
    describe command('git --version') do
      its(:stdout) { should match('2.6.2') }
    end
  end

  describe 'WiX' do
    let(:wix_version) { '3.10.0.2103' }

    describe command('heat.exe -help') do
      its(:stdout) { should match "Windows Installer XML Toolset Toolset Harvester version #{wix_version}" }
    end

    describe command('candle.exe -help') do
      its(:stdout) { should match "Windows Installer XML Toolset Compiler version #{wix_version}" }
    end

    describe command('light.exe -help') do
      its(:stdout) { should match "Windows Installer XML Toolset Linker version #{wix_version}" }
    end
  end

  describe 'Windows SDK' do
    describe command('signtool sign /?') do
      # `signtool.exe` returns output over STDERR... *sigh*
      its(:stderr) { should match 'Usage: signtool sign' }
    end
  end

  describe '7-zip' do
    describe command('7z -h') do
      its(:stdout) { should match '9.22' }
    end
  end

  describe 'environment' do
    # We are using regular Ruby because ServerSpec existent checks are failing on Windows
    describe omnibus_base_dir do
      it 'exists' do
        expect(File.directory?(omnibus_base_dir)).to be true
      end
    end

    [
      '.gitconfig',
      'load-omnibus-toolchain.bat',
    ].each do |env_file|
      # We are using regular Ruby because ServerSpec existent checks are failing on Windows
      describe env_file do
        it 'exists' do
          expect(File.exist?(File.join(build_user_home_dir, env_file))).to be true
        end
      end
    end
  end
end
