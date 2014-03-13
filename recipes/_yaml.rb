#
# Cookbook Name:: omnibus
# Recipe:: _yaml
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

#
# This recipe is used to install the platform-specific development headers for
# working with YAML (aka the native ruby bindings for YAML).
#

case node['platform_family']
when 'debian'
  package 'libyaml-dev'
when 'freebsd'
  package 'libyaml'
when 'mac_os_x'
  package 'libyaml'
when 'rhel'
  Chef::Log.debug 'No yaml packages for rhel'
end
