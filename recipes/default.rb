#
# Cookbook Name:: omnibus
# Recipe:: default
#
# Copyright 2013, Chef Software, Inc.
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

include_recipe 'omnibus::_common'

# Apply any platform-specific tweaks
begin
  include_recipe "omnibus::#{node['platform_family']}"
rescue Chef::Exceptions::RecipeNotFound
  Chef::Log.warn "An Omnibus platform recipe does not exist for the platform_family: #{node['platform_family']}"
end

include_recipe 'omnibus::_bash'   unless windows?
include_recipe 'omnibus::_ccache' unless windows?
include_recipe 'omnibus::_git'    unless windows?
include_recipe 'omnibus::_ruby'
include_recipe 'omnibus::_github'

case node['platform_family']
when 'debian', 'freebsd', 'rhel'
  include_recipe 'omnibus::_ccache'
end
