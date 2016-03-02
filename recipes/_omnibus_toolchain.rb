#
# Cookbook Name:: omnibus
# Recipe:: _omnibus_toolchain
#
# Copyright 2015, Chef Software, Inc.
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

if omnibus_toolchain_enabled?
  log 'omnibus_toolchain_enabled' do
    message "Omnibus Toolchain enabled. Proceeding with install of #{node['omnibus']['toolchain_name']}"
  end
else
  log 'omnibus_toolchain_not_enabled' do
    message 'Deciding not to install Omnibus Toolchain (package)'
  end
  return
end

chef_ingredient node['omnibus']['toolchain_name'] do
  product_name node['omnibus']['toolchain_name']
  version node['omnibus']['toolchain_version']
  channel :stable
end
