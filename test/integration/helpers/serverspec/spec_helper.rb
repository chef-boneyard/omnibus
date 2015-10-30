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
