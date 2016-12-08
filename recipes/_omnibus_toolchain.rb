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

chef_ingredient node['omnibus']['toolchain_name'] do
  version node['omnibus']['toolchain_version']
  channel node['omnibus']['toolchain_channel'].to_sym
  platform_version_compatibility_mode true
  if windows?
    action :install
  else
    action :upgrade
  end
end

omnibus_env['MSYSTEM'] << (windows_arch_i386? ? 'MINGW32' : 'MINGW64') if windows?
omnibus_env['OMNIBUS_TOOLCHAIN_INSTALL_DIR'] << toolchain_install_dir
omnibus_env['SSL_CERT_FILE'] << windows_safe_path_join(toolchain_install_dir, 'embedded', 'ssl', 'certs', 'cacert.pem')
