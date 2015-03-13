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

# solaris is a little different, we need to build some toolchains from source
if node['platform_family'] == 'solaris2'
  include_recipe 'omnibus::_solaris_build'
end

# Include other recipes. Note: they may not be executed in this order, since
# private recipes may depend on each other.
include_recipe 'omnibus::_bash'
include_recipe 'omnibus::_cacerts'
include_recipe 'omnibus::_ccache'
include_recipe 'omnibus::_chruby'
include_recipe 'omnibus::_compile'
# Installing ruby before git is the cleanest way to guarantee that
# on OS X, ownership of /usr/local/lib is correct for both the
# git install of perl5 and the homebrew install of libyaml.
include_recipe 'omnibus::_ruby'
include_recipe 'omnibus::_git'
include_recipe 'omnibus::_github'
include_recipe 'omnibus::_openssl'
include_recipe 'omnibus::_packaging'
include_recipe 'omnibus::_rsync'
include_recipe 'omnibus::_selinux'
include_recipe 'omnibus::_xml'
include_recipe 'omnibus::_yaml'

# Create environment loading scripts last
include_recipe 'omnibus::_environment'
