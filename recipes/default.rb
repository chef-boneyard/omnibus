#
# Cookbook Name:: omnibus
# Recipe:: default
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

# make certain our chef-solo cache dir exists
directory Chef::Config[:file_cache_path] do
  recursive true
  action :create
end

user node['omnibus']['build_user'] do
  action :create
  not_if { platform_family?("windows") }
end

[
  node['omnibus']['install_dir'],
  node['omnibus']['cache_dir']
].each do |dir|
  directory dir do
    mode 0755
    owner node["omnibus"]["build_user"]
    recursive true
  end
end

# apply any platform-specific tweaks
begin
  include_recipe "omnibus::#{node['platform_family']}"
rescue Chef::Exceptions::RecipeNotFound
  Chef::Log.warn "An Omnibus platform recipe does not exist for the platform_family: #{node['platform_family']}"
end

# install ruby and symlink the binaries to /usr/local
# TODO - use a proper Ruby cookbook for this
include_recipe "omnibus::ruby"
include_recipe "omnibus::github"
