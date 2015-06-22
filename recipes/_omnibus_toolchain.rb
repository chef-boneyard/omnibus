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

# These are sort of 'global' variables, independent of platform
toolchain_name = node['omnibus']['toolchain_name']
toolchain_version = node['omnibus']['toolchain_version']

if solaris_10?
  # create a nocheck file for automated install
  file '/var/sadm/install/admin/auto-install' do
    content <<-EOH.flush
      mail=
      instance=overwrite
      partial=nocheck
      runlevel=nocheck
      idepend=nocheck
      space=ask
      setuid=nocheck
      conflict=nocheck
      action=nocheck
      basedir=default
    EOH
    owner 'root'
    group 'root'
    mode '0444'
  end

  case node['kernel']['machine']
  when 'i86pc'
    package_url = "https://chef-releng.s3.amazonaws.com/omnibus/omnibus-toolchain/#{toolchain_name}-#{toolchain_version}-1.i86pc.solaris"
    package_checksum = 'eed0d5cc82c76dffd0052899a85ec96e3dc6915bdabc8d7c5c209028155744ea'
  when 'sun4v', 'sun4u'
    package_url = "https://chef-releng.s3.amazonaws.com/omnibus/omnibus-toolchain/#{toolchain_name}-#{toolchain_version}-1.sun4v.solaris"
    package_checksum = '3e4c676c1b3ba63b937ab37c04a1dba73c01ae27a0f60cf037d585dc5c329533'
  end

  package_name = File.basename(package_url)

  remote_file "#{Chef::Config[:file_cache_path]}/#{package_name}" do
    source package_url
    checksum package_checksum
  end

  package "#{node['omnibus']['toolchain_name']}" do
    source "#{Chef::Config[:file_cache_path]}/#{package_name}"
    options '-a auto-install'
  end
end
