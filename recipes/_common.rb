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

# Create a mostly unconfigured user, these
# duplicate entries in the _user recipe
# where things like login shell and home
# directory get added
group node['omnibus']['build_user_group'] do
  # The Window's group provider gets cranky if attempting to create a
  # built-in group.
  ignore_failure true if windows?
end

user node['omnibus']['build_user'] do
  unless windows? # rubocop:disable IfUnlessModifier
    gid node['omnibus']['build_user_group']
  end
end

# If we are on Solaris 11, we need to update some paths to favor the gnu utils
if solaris_11?
  unless ENV['PATH'].include? '/usr/gnu/bin'
    ENV['PATH'] = '/usr/gnu/bin:' + ENV['PATH']
    Chef::Log.info "Adding /usr/gnu/bin to path, now:\n#{ENV['PATH']}"
  end
end

include_recipe 'omnibus::_user'

# Ensure the cache directory exists
directory Chef::Config[:file_cache_path] do
  recursive true
end

# Create the omnibus directories
[
  node['omnibus']['base_dir'],
  node['omnibus']['install_dir']
].compact.each do |dir|
  directory dir do
    mode '0755'
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group']
    recursive true
  end
end
