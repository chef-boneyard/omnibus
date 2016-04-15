#
# Cookbook Name:: omnibus
# Recipe:: _omnibus_toolchain
#
# Copyright 2016, Chef Software, Inc.
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

log "omnibus-toolchain is #{omnibus_toolchain_enabled? ? 'enabled' : 'disabled'}"
return unless omnibus_toolchain_enabled?

chef_ingredient node['omnibus']['toolchain_name'] do
  version node['omnibus']['toolchain_version']
  channel :stable
end

# For omnibus builders - we want to symlink git to /usr/local/bin so that it
# is available in the machine's base path without having to worry about which
# toolchain (angry or not) is installed.
link '/usr/local/bin/git' do
  to "/opt/#{node['omnibus']['toolchain_name']}/embedded/bin/git"
end
