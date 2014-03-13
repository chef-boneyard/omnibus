#
# Cookbook Name:: omnibus
# Recipe:: _common
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

# Use homebrew as the default package manager on OSX
include_recipe 'homebrew::default' if mac_os_x?

# Ensure the cache directory exists
directory Chef::Config[:file_cache_path] do
  recursive true
end

# Create the profile.d
directory '/etc/profile.d' do
  action :create
  not_if { windows? }
end

# Create the onnibus user
user node['omnibus']['build_user'] do
  action :create
  not_if { windows? }
end

# Create the omnibus directories
[
  node['omnibus']['install_dir'],
  node['omnibus']['cache_dir'],
].each do |dir|
  directory dir do
    mode '0755'
    owner node['omnibus']['build_user']
    recursive true
  end
end
