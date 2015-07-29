#
# Cookbook Name:: omnibus
# Recipe:: _yum_repos
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

return unless rhel?

node['omnibus']['yum_repos'].map do |key, val|
  yum_repository key do
    description val[:description]
    baseurl val[:baseurl]
    gpgcheck val[:gpgcheck] if val[:gpgcheck]
    gpgkey val[:gpgkey] if val[:gpgkey]
    action :create
  end
end
