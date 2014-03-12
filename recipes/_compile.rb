#
# Cookbook Name:: omnibus
# Recipe:: _compile
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
# This recipe is used to install additional packages/utilities that are not
# included by default in the build-essential cookbook. In the long term, this
# recipe should just "go away" and the build-essential cookbook should become
# more awesome.
#

# There is a bug/feature in the OSX cookbook that installs a very old version
# of the XCode command line utilities.
include_recipe 'build-essential::default' unless mac_os_x?

case node['platform_family']
when 'debian'
  package 'ncurses-dev'
when 'freebsd'
  package 'gmake'
  package 'autoconf'
  package 'm4'
when 'mac_os_x'
  raise 'Need to fix build-essential for OSX'
when 'rhel'
when 'smartos'
  package 'autoconf'
  package 'binutils'
  package 'gcc47'
  package 'gmake'
  package 'pkg-config'
end
