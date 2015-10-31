require 'serverspec'
require 'pathname'
require 'tmpdir'

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM).nil?
  set :backend, :exec
else
  set :backend, :cmd
  set :os, family: 'windows'
end

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require_relative(file) }

set :path, '/sbin:/usr/local/sbin:/usr/bin:/bin'

def mac_os_x?
  os[:family] == 'darwin'
end

def windows?
  os[:family] == 'windows'
end

def home_dir
  if mac_os_x?
    '/Users/omnibus'
  elsif windows?
    'C:/Users/omnibus'
  else
    '/home/omnibus'
  end
end

#
# The following helpers convert platforms and platform versions into
# Omnibus-compatible values. See the following for more details:
#
# https://github.com/chef/omnibus/blob/v4.1.0/lib/omnibus/metadata.rb#L128-L212
#
def omnibus_platform(provided_platform)
  case provided_platform
  when 'redhat', 'centos'
    'el'
  else
    provided_platform
  end
end

def omnibus_platform_version(provided_platform, provided_platform_version)
  case provided_platform
  when 'debian', 'redhat', 'centos'
    provided_platform_version.split('.').first
  else
    provided_platform_version
  end
end
