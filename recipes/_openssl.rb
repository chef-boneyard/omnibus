#
# Cookbook Name:: omnibus
# Recipe:: _openssl
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

# Provided by the omnibus-build-essential project on Sol 10
return if solaris_10?
#
# This recipe is used to install the platform-specific development headers for
# working with openssl.
#

if debian?
  package 'libssl-dev'
elsif freebsd?
  # OpenSSL development headers are part of the base install
elsif mac_os_x?
  package 'openssl'
elsif suse?
  package 'zlib-devel' # zypper provider fails on openssl-devel without
  package 'libopenssl-devel'

  # TODO: may need to force link.
  # See: http://stackoverflow.com/questions/17477933
elsif rhel?
  package 'openssl-devel'
end
