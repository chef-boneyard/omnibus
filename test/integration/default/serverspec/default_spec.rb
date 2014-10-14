require 'serverspec'
require 'pathname'

set :backend, :exec

home_dir = if os[:family] == 'darwin'
             '/Users/omnibus'
           else
             '/home/omnibus'
           end

describe group('omnibus') do
  it { should exist }
end

describe user('omnibus') do
  it { should exist }
  it { should have_login_shell '/bin/bash' }
end

describe command('pkgutil --pkg-info=com.apple.pkg.CLTools_Executables'), if: os[:family] == 'darwin' do
  its(:exit_status) { should eq 0 }
end

describe 'ccache' do
  describe command('/usr/local/bin/ccache --version') do
    its(:stdout) { should match(/3\.1\.9/) }
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
  describe command("su - omnibus -c 'source ~/.bashrc && which ruby'") do
    its(:stdout) { should match '/opt/rubies/ruby-2.1.2/bin/ruby' }
  end

  describe command("su - omnibus -l -c 'source ~/.bashrc && ruby --version'") do
    its(:stdout) { should match(/2\.1\.2/) }
  end
end

describe 'bash' do
  describe command('/usr/local/bin/bash --version') do
    its(:stdout) { should match(/4\.3/) }
  end
end

describe 'git' do
  describe command('/usr/local/bin/git --version') do
    its(:stdout) { should match(/1\.9\.0/) }
  end
end

describe 'rsync' do
  describe command('/usr/local/bin/rsync --version') do
    its(:stdout) { should match(/3\.1\.0/) }
  end
end

describe 'environment' do
  describe '$PATH' do
    # On RHEL, +sudo+ does not execute a login shell by default. We can't simply
    # check the $PATH because ServerSpec doesn't execute a login shell
    # automatically.
    describe command("su - omnibus -c 'echo $PATH'") do
      its(:stdout) { should match %r{^/usr/local/bin(.+)} }
    end
  end

  describe file(File.join(home_dir, 'load-omnibus-toolchain.sh')) do
    it { should be_file }
    # it { should be_owned_by 'omnibus' }
    # it { should be_grouped_into 'omnibus' }
  end

  [
    '.gitconfig',
    '.bash_profile',
    '.bashrc',
    File.join('.bashrc.d', 'omnibus-path.sh'),
    File.join('.bashrc.d', 'chruby-default.sh'),
  ].each do |dot_file|

    describe file(File.join(home_dir, dot_file)) do
      it { should be_file }
      # it { should be_owned_by 'omnibus' }
      # it { should be_grouped_into 'omnibus' }
    end

  end
end
