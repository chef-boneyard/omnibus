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

if RUBY_PLATFORM =~ /darwin/
  describe command('pkgutil --pkg-info=com.apple.pkg.CLTools_Executables') do
    it { should return_exit_status 0 }
  end
end

describe 'ccache' do
  describe command('/usr/local/bin/ccache --version') do
    it { should return_stdout(/3\.1\.9/) }
  end

  %w[gcc g++ cc c++].each do |compiler|
    describe file("/usr/local/bin/#{compiler}") do
      it { should be_linked_to('/usr/local/bin/ccache') }
    end
  end
end

describe 'ruby' do
  describe command('/usr/local/bin/ruby --version') do
    it { should return_stdout(/^ruby 2\.1\.1(.+)/) }
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
