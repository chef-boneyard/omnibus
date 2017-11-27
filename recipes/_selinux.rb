#
# Cookbook Name:: omnibus
# Recipe:: _selinux
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

return unless !docker? && rhel?

# Omnibus requires SELinux be in a permissive state or rsync commands will fail
execute 'selinux-permissive' do
  command 'setenforce 0'
  environment 'PATH' => "#{ENV['PATH']}:/sbin:/usr/sbin"
  not_if  'getenforce | egrep -qx "Permissive|Disabled"'
end

file '/etc/selinux/config' do
  content <<-EOH.gsub(/^ {4}/, '')
    SELINUX=permissive
    SELINUXTYPE=targeted
  EOH
end
