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

#
# This recipe is used to install the platform-specific development headers for
# working with openssl.
#

case node['platform_family']
when 'debian'
  package 'libssl-dev'
when 'freebsd'
  package 'openssl'
when 'mac_os_x'
  package 'openssl'

  # TODO: may need to force link.
  # See: http://stackoverflow.com/questions/17477933
when 'rhel'
  package 'openssl-devel'
when 'smartos'
  package 'openssl'
end
