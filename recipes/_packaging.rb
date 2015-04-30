#
# Cookbook Name:: omnibus
# Recipe:: _packaging
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

# Include the common recipe
include_recipe 'omnibus::_common'

#
# This recipe is used to install the "packaging" components.
#

if debian?
  package 'devscripts'
  package 'dpkg-dev'
  package 'fakeroot'
  package 'ncurses-dev'
  package 'zlib1g-dev'
elsif freebsd?
  package 'devel/ncurses'
elsif rhel?
  if node['platform_version'].satisfies?('>= 7') && (ppc64? || ppc64le?)
    include_recipe 'omnibus::_fakeroot'
  else
    package 'fakeroot'
  end
  package 'ncurses-devel'
  package 'rpm-build'
  package 'zlib-devel'
  # EL 7 split rpm-sign into its own package:  http://cholla.mmto.org/computers/linux/rpm/signing.html
  package 'rpm-sign' if node['platform_version'].satisfies?('>= 7')
  # EL 6 and later consider glibc-static optional: https://access.redhat.com/solutions/33868
  # The libhugetlbfs build (analytics) requires it.
  package 'glibc-static' if node['platform_version'].satisfies?('>= 6', '<= 7')

  # This script makes unattended rpm signing possible!
  cookbook_file ::File.join(build_user_home, 'sign-rpm') do
    source 'sign-rpm'
    mode '0755'
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group']
    mode '0755'
  end
elsif windows?
  include_recipe '7-zip::default'
  include_recipe 'wix::default'

  omnibus_env['PATH'] << node['wix']['home']
  omnibus_env['PATH'] << node['7-zip']['home']
end
