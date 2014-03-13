#
# Cookbook Name:: omnibus
# Recipe:: _git
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

include_recipe 'omnibus::_bash'
include_recipe 'omnibus::_common'
include_recipe 'omnibus::_compile'
include_recipe 'omnibus::_openssl'

case node['platform_family']
when 'debian'
  package 'libcurl4-gnutls-dev'
  package 'libexpat1-dev'
  package 'gettext'
  package 'libz-dev'
  package 'perl-modules'
when 'freebsd'
  package 'curl'
  package 'expat2'
  package 'gettext'
  package 'libzip'
  package 'perl5' do
    source 'ports'
    not_if 'perl -v | grep "perl 5"'
  end
when 'mac_os_x'
  package 'curl'
  package 'expat'
  package 'gettext'
when 'rhel'
  package 'curl-devel'
  package 'expat-devel'
  package 'gettext-devel'
  package 'perl-ExtUtils-MakeMaker'
  package 'zlib-devel'
when 'smartos'
  package 'curl'
  package 'expat'
  package 'gettext'
end

# For whatever reason, FreeBSD requires gmake instead of make
make = freebsd? ? 'gmake' : 'make'

remote_install 'git' do
  source 'https://github.com/git/git/archive/v1.9.0.tar.gz'
  checksum '064f2ee279cc05f92f0df79c1ca768771393bc3134c0fa53b17577679383f039'
  version '1.9.0'
  build_command "#{make} prefix=/usr/local all"
  install_command "#{make} prefix=/usr/local install"
  not_if { installed_at_version?('git', '1.9.0') }
end
