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

include_recipe 'chef-sugar::default'

if windows?
  include_recipe 'omnibus::_ruby_windows'
else
  include_recipe 'build-essential::default'

  # Install ruby-install so we can easily install and manage rubies. This is
  # needed by the +ruby_install+ HWRP which installs rubies for us.
  remote_install 'ruby-install' do
    source 'https://github.com/postmodern/ruby-install/archive/v0.4.1.tar.gz'
    checksum '1b35d2b6dbc1e75f03fff4e8521cab72a51ad67e32afd135ddc4532f443b730e'
    version '0.4.1'
    install_command 'make install'
    not_if { installed_at_version?('ruby-install', '0.4.1') }
  end

  # Install the version of Ruby we want into /usr/local
  ruby_install node['omnibus']['ruby_version']

  # Install bundler (into the Ruby we just installed)
  ruby_gem 'bundler'
end
