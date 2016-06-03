#
# Cookbook Name:: omnibus
# Recipe:: _fakeroot_package
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

platform_version =
  if node['platform_version'].satisfies?('~> 7')
    7
  elsif node['platform_version'].satisfies?('~> 6')
    6
  else
    8
  end

# add the EPEL repo for fakeroot if we're on centos
yum_repository 'epel' do
  description 'Extra Packages for Enterprise Linux'
  mirrorlist "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-#{platform_version}&arch=$basearch"
  gpgkey "http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-#{platform_version}"
  only_if { centos? }
  action :create
end

package 'fakeroot'
