#
# Cookbook Name:: omnibus
# Recipe:: _ruby_install
#
# Copyright 2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Include the common recipe
include_recipe 'omnibus::_common'

# Provided by the omnibus-toolchain package
return if omnibus_toolchain_enabled?

unless windows?
  include_recipe 'omnibus::_bash'
  include_recipe 'omnibus::_cacerts'
  include_recipe 'omnibus::_chruby'
  include_recipe 'omnibus::_compile'
  include_recipe 'omnibus::_openssl'
  include_recipe 'omnibus::_xml'
  include_recipe 'omnibus::_yaml'

  # The RHEL 7 EC2 images do not include bzip2, which is a dep of ruby-install.
  package 'bzip2' if rhel?

  # Install ruby-install so we can easily install and manage rubies. This is
  # needed by the +ruby_install+ HWRP which installs rubies for us.
  remote_install 'ruby-install' do
    source 'https://codeload.github.com/postmodern/ruby-install/tar.gz/v0.4.1'
    checksum '1b35d2b6dbc1e75f03fff4e8521cab72a51ad67e32afd135ddc4532f443b730e'
    version '0.4.1'
    install_command "make -j #{node.builders} install"
    not_if { installed_at_version?('ruby-install', '0.4.1') }
  end
end

build_env = {}
patches   = []

#
# Taken from the omnibus-software/ruby
#
#   https://github.com/chef/omnibus-software/blob/38e8befd5ecd14b7ad32c4bd3118fe4caf79ee92/config/software/ruby.rb
#
if solaris_11?
  build_env['CC']   =  '/usr/sfw/bin/gcc'
  build_env['MAKE'] = 'gmake'

  if sparc?
    build_env['CFLAGS']  = '-O0 -g -pipe -mcpu=v9'
    build_env['LDFLAGS'] = '-mcpu=v9'
  end

  patches << 'https://raw.githubusercontent.com/chef/omnibus-software/38e8befd5ecd14b7ad32c4bd3118fe4caf79ee92/config/patches/ruby/ruby-solaris-linux-socket-compat.patch'
end

# Install the version of Ruby we want into /usr/local
ruby_install node['omnibus']['ruby_version'] do
  environment build_env
  patches     patches
end

# Install bundler (into the Ruby we just installed)
ruby_gem 'bundler' do
  ruby node['omnibus']['ruby_version']
end

if windows?
  ruby_base_path = windows_safe_path_join(ENV['SYSTEMDRIVE'], 'rubies', node['omnibus']['ruby_version'])
  omnibus_env['PATH'] << windows_safe_path_join(ruby_base_path, 'bin')
  omnibus_env['PATH'] << windows_safe_path_join(ruby_base_path, 'mingw', 'bin')
  omnibus_env['SSL_CERT_FILE'] << windows_safe_path_join(ruby_base_path, 'ssl', 'certs', 'cacert.pem')
end
