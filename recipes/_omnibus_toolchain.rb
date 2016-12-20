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

if windows?
  toolchain_options = {
    product_name: node['omnibus']['toolchain_name'],
    product_version: node['omnibus']['toolchain_version'],
    channel: node['omnibus']['toolchain_channel'].to_sym,
    # Override detected architecture on Windows as we use properly
    # configured 64-bit instances to compile things in 32-bit mode.
    architecture: (windows_arch_i386? ? 'i386' : 'x86_64')
  }

  artifact_info = mixlib_install_artifact_info_for(toolchain_options)
  begin
    remote_artifact_path = artifact_info.url
  rescue NoMethodError
    raise "The version #{toolchain_options[:product_version]} of the toolchain #{toolchain_options[:product_name]} does not exist in the channel #{toolchain_options[:channel]}."
  end
  local_artifact_path  = ::File.join(Chef::Config[:file_cache_path], ::File.basename(remote_artifact_path))

  remote_file local_artifact_path do
    source remote_artifact_path
    mode '0644'
    checksum artifact_info.sha256
    backup 1
  end

  omnibus_env['MSYSTEM'] << mingw_toolchain_name.upcase
  omnibus_env['OMNIBUS_WINDOWS_ARCH'] << (windows_arch_i386? ? 'x86' : 'x64')
  omnibus_env['BASH_ENV'] << msys2_path(windows_safe_path_join(toolchain_install_dir, 'embedded', 'bin', 'etc', 'msys2.bashrc'))
end

chef_ingredient node['omnibus']['toolchain_name'] do
  version node['omnibus']['toolchain_version']
  channel node['omnibus']['toolchain_channel'].to_sym
  platform_version_compatibility_mode true
  if windows?
    package_source local_artifact_path
    action :install
  else
    action :upgrade
  end
end

omnibus_env['OMNIBUS_TOOLCHAIN_INSTALL_DIR'] << toolchain_install_dir
omnibus_env['SSL_CERT_FILE'] << windows_safe_path_join(toolchain_install_dir, 'embedded', 'ssl', 'certs', 'cacert.pem')
