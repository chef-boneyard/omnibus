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

if File.exist?("/opt/#{toolchain_name}/version-manifest.json") &&
   (JSON.parse(File.read("/opt/#{toolchain_name}/version-manifest.json"))['build_version'] == toolchain_version)

  Chef::Log.info("`#{toolchain_name}` is already installed at version #{toolchain_version}.")
else
  install_options = ''
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
        conflict=nocheckit
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
    when 'sun4v', 'sun4u'
      package_url = "https://chef-releng.s3.amazonaws.com/omnibus/omnibus-toolchain/#{toolchain_name}-#{toolchain_version}-1.sun4v.solaris"
    end

    install_options = '-a auto-install'
  elsif aix?
    package_url = "http://chef-releng.s3.amazonaws.com/omnibus/omnibus-toolchain/#{toolchain_name}-#{toolchain_version}-1.powerpc.bff"
  else
    Chef::Application.fatal!("I don't know how to install #{node['omnibus']['toolchain_name']} on this platform!", 1)
  end

  package_path = File.join(Chef::Config[:file_cache_path], File.basename(package_url))

  remote_file package_path do
    source package_url
    action :create_if_missing
  end

  package node['omnibus']['toolchain_name'] do
    source package_path
    options install_options
  end
end
