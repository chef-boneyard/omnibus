require 'serverspec'
require 'pathname'
require 'tmpdir'

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM).nil?
  set :backend, :exec
  set :path, '/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/bin:/bin'
else
  set :backend, :cmd
  set :os, family: 'windows'
  set :path, 'C:/Program Files (x86)/Git/Cmd;C:/Program Files (x86)/Git/libexec/git-core;C:/wix;C:/Program Files/7-Zip;C:\Program Files (x86)\Windows Kits\8.1\bin\x64'
end

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |file| require_relative(file) }

def mac_os_x?
  os[:family] == 'darwin'
end

def windows?
  os[:family] == 'windows'
end

def build_user_home_dir
  home_dir(build_user)
end

def build_user
  'omnibus'
end

def home_dir(user)
  if mac_os_x?
    "/Users/#{user}"
  elsif windows?
    "C:/#{user}"
  else
    "/home/#{user}"
  end
end

def omnibus_base_dir
  if windows?
    'C:/omnibus-ruby'
  else
    '/var/cache/omnibus'
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
  when 'centos', 'redhat'
    'el'
  when 'darwin'
    'mac_os_x'
  else
    provided_platform
  end
end

def omnibus_platform_version(provided_platform, provided_platform_version)
  case provided_platform
  when 'debian', 'redhat', 'centos'
    provided_platform_version.split('.').first
  when 'darwin', 'mac_os_x'
    # specinfra returns the `darwin` version...we want the OS X version.
    # We'll compute this the same way Ohai does:
    #
    #   https://github.com/chef/ohai/blob/master/lib/ohai/plugins/darwin/platform.rb
    #
    pv = `/usr/bin/sw_vers`.split(/^ProductVersion:\s+(.+)$/)[1]
    pv.split('.')[0..1].join('.')
  else
    provided_platform_version
  end
end
