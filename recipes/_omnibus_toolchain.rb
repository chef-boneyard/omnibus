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

arch = (windows_arch_i386? || i386?) ? 'i386' : node['kernel']['machine']

# Throwing a huge if/else here for ease of removal later
if suse? && intel?
  mapped_version = nil
  if node['platform_version'] =~ /11.*/
    mapped_version = '5'
  elsif node['platform_version'] =~ /12.*/
    mapped_version = '6'
  end

  chef_ingredient node['omnibus']['toolchain_name'] do
    platform 'el'
    platform_version mapped_version
    version node['omnibus']['toolchain_version']
    channel node['omnibus']['toolchain_channel'].to_sym
    architecture arch
    platform_version_compatibility_mode true
    action(windows? ? :install : :upgrade)
  end
else
  chef_ingredient node['omnibus']['toolchain_name'] do
    version node['omnibus']['toolchain_version']
    channel node['omnibus']['toolchain_channel'].to_sym
    architecture arch
    platform_version_compatibility_mode true
    action(windows? ? :install : :upgrade)
  end
end

omnibus_env['OMNIBUS_TOOLCHAIN_INSTALL_DIR'] << toolchain_install_dir
omnibus_env['SSL_CERT_FILE'] << windows_safe_path_join(toolchain_install_dir, 'embedded', 'ssl', 'certs', 'cacert.pem')

if windows?
  omnibus_env['MSYSTEM'] << mingw_toolchain_name.upcase
  omnibus_env['OMNIBUS_WINDOWS_ARCH'] << (windows_arch_i386? ? 'x86' : 'x64')
  omnibus_env['BASH_ENV'] << windows_safe_path_join(toolchain_install_dir, 'embedded', 'bin', 'etc', 'msys2.bashrc')
end
