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

# Ensure omnibus user is created
describe user('omnibus') do
  it { should exist }
end

# Ensure required build dirs exist
describe file('/opt/omnibus') do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'omnibus' }
end
describe file('/var/cache/omnibus') do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by 'omnibus' }
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
