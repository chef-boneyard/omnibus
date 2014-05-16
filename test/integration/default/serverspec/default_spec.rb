require 'serverspec'
require 'pathname'

include Serverspec::Helper::Exec

# serverspec's FreeBSD support is craptastic. We'll just make it think
# it's executing on OS X.
if RUBY_PLATFORM =~ /freebsd/
  include Serverspec::Helper::Darwin
else
  include Serverspec::Helper::DetectOS
end

home_dir = if RUBY_PLATFORM =~ /darwin/
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

if RUBY_PLATFORM =~ /darwin/
  describe command('pkgutil --pkg-info=com.apple.pkg.CLTools_Executables') do
    it { should return_exit_status 0 }
  end
end

describe 'ccache' do
  describe command('/usr/local/bin/ccache --version') do
    it { should return_stdout(/3\.1\.9/) }
  end

  %w(gcc g++ cc c++).each do |compiler|
    describe file("/usr/local/bin/#{compiler}") do
      it { should be_linked_to('/usr/local/bin/ccache') }
    end
  end
end

describe 'ruby' do
  describe command("su - omnibus -c 'source ~/.bashrc && which ruby'") do
    it { should return_stdout('/opt/rubies/ruby-2.1.1/bin/ruby') }
  end

  describe command("su - omnibus -l -c 'source ~/.bashrc && ruby --version'") do
    it { should return_stdout(/2\.1\.1/) }
  end
end

describe 'bash' do
  describe command('/usr/local/bin/bash --version') do
    it { should return_stdout(/4\.3/) }
  end
end

describe 'git' do
  describe command('/usr/local/bin/git --version') do
    it { should return_stdout(/1\.9\.0/) }
  end
end

describe 'environment' do
  describe '$PATH' do
    # On RHEL, +sudo+ does not execute a login shell by default. We can't simply
    # check the $PATH because ServerSpec doesn't execute a login shell
    # automatically.
    describe command("su - omnibus -c 'echo $PATH'") do
      it { should return_stdout(%r{^/usr/local/bin(.+)}) }
    end
  end

  describe file(File.join(home_dir, 'load-omnibus-toolchain.sh')) do
    it { should be_file }
    it { should be_owned_by 'omnibus' }
    it { should be_grouped_into 'omnibus' }
  end

  [
    '.gitconfig',
    '.bash_profile',
    '.bashrc',
    File.join('.bashrc.d', 'omnibus-path.sh'),
    File.join('.bashrc.d', 'chruby-default.sh')
  ].each do |dot_file|

    describe file(File.join(home_dir, dot_file)) do
      it { should be_file }
      it { should be_owned_by 'omnibus' }
      it { should be_grouped_into 'omnibus' }
    end

  end
end
