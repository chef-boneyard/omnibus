#
# Cookbook Name:: omnibus
# Recipe:: _xml
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
# working with XML (aka the nokogiri gem).
#

case node['platform_family']
when 'debian'
  package 'libxml2-dev'
  package 'libxslt-dev'
  package 'ncurses-dev'
  package 'zlib1g-dev'
when 'freebsd'
  package 'libxml2'
  package 'libxslt'
  package 'ncurses'
when 'mac_os_x'
  package 'libxml2'
  package 'libxslt'
when 'rhel'
  package 'libxml2-devel'
  package 'libxslt-devel'
  package 'ncurses-devel'
  package 'zlib-devel'
end
