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

describe command('which ruby') do
  it { should return_stdout('/usr/local/bin/ruby') }
end

describe command('/usr/local/bin/ruby --version') do
  it { should return_stdout(/^ruby 2\.1\.1(.+)/) }
end

describe file('/usr/local/bin/ccache') do
  it { should be_executable }
end

%w[gcc g++ cc c++].each do |compiler|
  describe file("/usr/local/bin/#{compiler}") do
    it { should be_linked_to '/usr/local/bin/ccache' }
  end
end
