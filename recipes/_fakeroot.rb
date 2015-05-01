#
# Cookbook Name:: omnibus
# Recipe:: _fakeroot
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

# Include the common recipe
include_recipe 'omnibus::_common'

include_recipe 'omnibus::_compile'

package 'libcap-devel' # required to build fakeroot

remote_install 'fakeroot' do
  # source code is maintained on debian ftp
  source 'ftp://ftp.debian.org/debian/pool/main/f/fakeroot/fakeroot_1.20.2.orig.tar.bz2'
  relative_path 'fakeroot-1.20.2'
  version '1.20.2'
  checksum '7c0a164d19db3efa9e802e0fc7cdfeff70ec6d26cdbdc4338c9c2823c5ea230c'
  build_command './configure'
  compile_command "make -j #{node.builders}"
  install_command 'make install'
  not_if { installed_at_version?('/usr/bin/fakeroot', '1.20.2') }
end
