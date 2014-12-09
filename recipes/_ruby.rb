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

case node['platform_family']
when 'solaris2'
  include_recipe 'omnibus::_bash'
  include_recipe 'omnibus::_cacerts'
  include_recipe 'omnibus::_chruby'
  include_recipe 'omnibus::_compile'
  include_recipe 'omnibus::_openssl'
  include_recipe 'omnibus::_xml'
  include_recipe 'omnibus::_yaml'

  toolchain_env =
  { 'GREP' => 'ggrep',
    'CC' => '/usr/local/bin/gcc -m64',
    'CXX' => '/usr/local/bin/g++ -m64',
    'LD' => '/usr/local/bin/ld -64',
    'LD_LIBRARY_PATH' => '/usr/local/lib/amd64:/usr/sfw/lib/amd64:/usr/local/lib:/usr/sfw/lib',
  }

  # install libyaml so ruby supports psych
  remote_install 'libyaml' do
    source 'http://pyyaml.org/download/libyaml/yaml-0.1.5.tar.gz'
    checksum 'fa87ee8fb7b936ec04457bc044cd561155e1000a4d25029867752e543c2d3bef'
    version '0.1.5'
    build_command './configure'
    compile_command 'make'
    install_command 'make install'
    environment toolchain_env
    not_if do
      File.exist?('/usr/local/lib/libyaml.so')
    end
  end

  # ruby-install doesn't work very well on solaris for unknown reasons.
  remote_install 'ruby' do
    source "http://cache.ruby-lang.org/pub/ruby/2.1/ruby-#{node['omnibus']['ruby_version']}.tar.gz"
    checksum 'f22a6447811a81f3c808d1c2a5ce3b5f5f0955c68c9a749182feb425589e6635'
    version '2.1.2'
    build_command "./configure --disable-install-rdoc --disable-install-ri --with-out-ext=tcl --with-out-ext=tk --without-tcl --without-tk --disable-dtrace --with-opt-dir=/usr/local --with-openssl-dir=/usr/local --prefix=/opt/rubies/ruby-#{node['omnibus']['ruby_version']}"
    compile_command 'make'
    install_command 'make install'
    environment toolchain_env
    not_if do
      File.exist?("/opt/rubies/ruby-#{node['omnibus']['ruby_version']}/bin/ruby")
    end
  end

  ruby_gem 'bundler' do
    ruby node['omnibus']['ruby_version']
  end

when 'windows'

  # Install the version of Ruby we want into /usr/local
  ruby_install node['omnibus']['ruby_version']

  # Install bundler (into the Ruby we just installed)
  ruby_gem 'bundler' do
    ruby node['omnibus']['ruby_version']
  end

  ruby_base_path = windows_safe_path_join(ENV['SYSTEMDRIVE'], 'rubies', node['omnibus']['ruby_version'])
  omnibus_env['PATH'] << windows_safe_path_join(ruby_base_path, 'bin')
  omnibus_env['PATH'] << windows_safe_path_join(ruby_base_path, 'mingw', 'bin')
  omnibus_env['SSL_CERT_FILE'] << windows_safe_path_join(ruby_base_path, 'ssl', 'certs', 'cacert.pem')

else
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

  ruby_install node['omnibus']['ruby_version']

  ruby_gem 'bundler' do
    ruby node['omnibus']['ruby_version']
  end

end
