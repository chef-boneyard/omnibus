#
# Cookbook Name:: omnibus
# Recipe:: default
#
# Copyright 2013-2014, Chef Software, Inc.
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

# Include the common recipe
include_recipe 'omnibus::_common'

# Install the omnibus-toolchain package
include_recipe 'omnibus::_omnibus_toolchain'

# Include other recipes. Note: they may not be executed in this order, since
# private recipes may depend on each other.
include_recipe 'omnibus::_compile'
include_recipe 'omnibus::_git'
include_recipe 'omnibus::_github'
include_recipe 'omnibus::_libffi'
include_recipe 'omnibus::_packaging'
include_recipe 'omnibus::_selinux'

# Create environment loading scripts last
include_recipe 'omnibus::_environment'
