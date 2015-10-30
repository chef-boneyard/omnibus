require 'spec_helper'

describe group('omnibus'), pending: (os[:family] == 'darwin') do
  it { should exist }
end

describe user('omnibus') do
  it { should exist }
  it('', pending: os[:family] == 'darwin') { should have_login_shell '/usr/local/bin/bash' }
end

describe command('pkgutil --pkg-info=com.apple.pkg.CLTools_Executables'), if: os[:family] == 'darwin' do
  its(:exit_status) { should eq 0 }
end

describe 'ccache' do
  describe command('/usr/local/bin/ccache --version') do
    its(:stdout) { should match('3.1.9') }
  end

  # FreeBSD 10+ uses clang
  compilers = if (os[:family] == 'freebsd') && (os[:release] == 10)
                %w(cc c++)
              else
                %w(gcc g++ cc c++)
              end

  compilers.each do |compiler|
    describe file("/usr/local/bin/#{compiler}") do
      it { should be_linked_to('/usr/local/bin/ccache') }
    end
  end
end

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
    its(:stdout) { should match('1.9.0') }
  end

  # Ensure `https` remote functions correctly
  Dir.mktmpdir('omnibus') do |tmpdir|
    # Ensure HTTPS remote support works
    describe command("git clone https://github.com/chef-cookbooks/omnibus.git #{tmpdir}") do
      its(:exit_status) { should eq 0 }
    end
  end
end

describe 'environment' do
  describe '$PATH' do
    # On RHEL, +sudo+ does not execute a login shell by default. We can't simply
    # check the $PATH because ServerSpec doesn't execute a login shell
    # automatically.
    describe command("su - omnibus -l -c 'echo $PATH'") do
      its(:stdout) { should match %r{^/usr/local/bin(.+)} }
    end
  end

  describe '$SSL_CERT_FILE', if: os[:family] == 'freebsd' do
    describe command("su - omnibus -l -c 'echo $SSL_CERT_FILE'") do
      its(:stdout) { should match %r{^/usr/local/share/certs/ca-root-nss.crt} }
    end
  end

  describe file(File.join(home_dir, 'load-omnibus-toolchain.sh')) do
    it { should be_file }

    describe command("su - omnibus -l -c 'source ~/load-omnibus-toolchain.sh && which ruby'") do
      its(:stdout) { should match %r{/opt/languages/ruby/2.1.5/bin/ruby$} }
    end
  end

  [
    '.gitconfig',
    '.bash_profile',
    '.bashrc',
    File.join('.bashrc.d', 'omnibus-path.sh')
  ].each do |dot_file|
    describe file(File.join(home_dir, dot_file)) do
      it { should be_file }
      # it { should be_owned_by 'omnibus' }
      # it { should be_grouped_into 'omnibus' }
    end
  end

  describe file(File.join(home_dir, 'sign-rpm')), if: os[:family] == 'redhat' do
    it { should be_file }
    it { should be_owned_by 'omnibus' }
    it { should be_grouped_into 'omnibus' }
  end

  describe file('/etc/make.conf'), if: os[:family] == 'freebsd' do
    it { should be_file }
    its(:content) { should match(/\.MAKEFLAGS: -B/) }
  end

  describe file('/etc/ssl/cert.pem'), if: os[:family] == 'freebsd' do
    it { should be_symlink }
  end
end
