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

include_recipe 'build-essential::default'
include_recipe 'chef-sugar::default'

case node['platform_family']
when 'debian'
  package 'libcurl4-gnutls-dev'
  package 'libexpat1-dev'
  package 'gettext'
  package 'libz-dev'
  package 'libssl-dev'
when 'rhel'
  package 'curl-devel'
  package 'expat-devel'
  package 'gettext-devel'
  package 'openssl-devel'
  package 'zlib-devel'
end

remote_install 'git' do
  source 'https://github.com/git/git/archive/v1.9.0.tar.gz'
  checksum '064f2ee279cc05f92f0df79c1ca768771393bc3134c0fa53b17577679383f039'
  version '1.9.0'
  build_command 'make prefix=/usr/local all'
  install_command 'make prefix=/usr/local install'
  not_if { installed_at_version?('git', '1.9.0') }
end
