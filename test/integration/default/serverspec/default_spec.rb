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
     it { should return_exit_status 0}
  end
end

# Ensure rbenv Ruby is linked to /usr/local/bin
describe command('/usr/local/bin/ruby --version') do
  it { should return_stdout(/^ruby 1.9.3/) }
end

# Ensure all rbenv shims are linked to /usr/local/bin
%w{ bundle erb gem irb rake rdoc ri ruby testrb }.each do |shim|
  describe file("/usr/local/bin/#{shim}") do
    it { should be_linked_to "/opt/rbenv/shims/#{shim}" }
  end
end

# Ensure ccache is installed and linked in
describe file('/usr/local/bin/ccache') do
  it { should be_executable }
end
%w{ gcc g++ cc c++ }.each do |compiler|
  describe file("/usr/local/bin/#{compiler}") do
    it { should be_linked_to '/usr/local/bin/ccache' }
  end
end
