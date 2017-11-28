#
# Cookbook Name:: omnibus
# Recipe:: _libffi
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

# We need libffi 3.2.1 on ppc64/ppc64le systems in order
# for ruby ffi gem to get installed. Someday when ruby ffi
# updates embedded libffi 3.2.1 and fixes its extension
# build process to consume embedded libffi properly this wont
# be required. https://github.com/ffi/ffi/pull/424#issuecomment-83935000

# Include the common recipe
include_recipe 'omnibus::_common'

return unless ppc64? || ppc64le?

include_recipe 'omnibus::_compile'

require 'pkg-config'

# libffi.pc is installed at below path and its not default
# search paths for pkg-config
build_env = {}
build_env['PKG_CONFIG_PATH'] = '/usr/local/lib/pkgconfig/'

remote_install 'libffi' do
  # source code is maintained on debian ftp
  source 'ftp://sourceware.org/pub/libffi/libffi-3.2.1.tar.gz'
  version '3.2.1'
  checksum 'd06ebb8e1d9a22d19e38d63fdb83954253f39bedc5d46232a05645685722ca37'
  environment build_env
  build_command './configure'
  compile_command "make -j #{node.builders}"
  install_command 'make install'
  not_if { ::PKGConfig.check_version?('libffi', 3, 2, 1) }
end
