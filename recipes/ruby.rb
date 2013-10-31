#
# Cookbook Name:: omnibus
# Recipe:: ruby
#
# Copyright 2013, Opscode, Inc.
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

case node['platform_family']
when 'windows'
  include_recipe 'omnibus::ruby_windows'
when 'smartos'

  pkgin_package 'ruby193'

  gem_package 'bundler' do
    version '1.3.5'
    gem_binary '/opt/local/bin/gem'
    options '--bindir=/opt/local/bin'
  end

else

  include_recipe 'rbenv::default'
  include_recipe 'rbenv::ruby_build'

  rbenv_ruby node['omnibus']['ruby_version'] do
    global true
  end

  rbenv_gem 'bundler' do
    ruby_version node['omnibus']['ruby_version']
    version '1.3.5'
  end

  # link rbenv's shims for the ruby toolchain into a known path
  %w{ bundle erb gem irb rake rdoc ri ruby testrb }.each do |shim|
    user_local_path = "/usr/local/bin/#{shim}"
    link user_local_path do
      to ::File.join(node['rbenv']['root'], 'shims', shim)
    end
  end
end
