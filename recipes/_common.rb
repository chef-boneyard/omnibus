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

# Include Chef Sugar here
include_recipe 'chef-sugar::default'
require 'chef/sugar/core_extensions'

# Create the user
include_recipe 'omnibus::_user'

# Ensure the cache directory exists
directory Chef::Config[:file_cache_path] do
  recursive true
end

# If we are on Solaris 11, we need to update some paths to favor the gnu utils
if solaris_11?
  unless ENV['PATH'].include? '/usr/gnu/bin'
    Chef::Log.debug 'Adding /usr/gnu/bin to path'
    ENV['PATH'] = '/usr/gnu/bin:' + ENV['PATH']
  end
end

# Create the omnibus directories
[
  node['omnibus']['cache_dir'],
  node['omnibus']['install_dir']
].compact.each do |dir|
  directory dir do
    mode '0755'
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group']
    recursive true
  end
end
