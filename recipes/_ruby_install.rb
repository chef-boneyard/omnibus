#
# Cookbook Name:: omnibus
# Recipe:: _ruby_install
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

# This should NOT be a node attribute
version = '0.4.1'

remote_file "#{Chef::Config[:file_cache_path]}/ruby-install-#{version}.tar.gz" do
  source   "https://github.com/postmodern/ruby-install/archive/v#{version}.tar.gz"
  notifies :run, "execute[install ruby-install-#{version}]", :immediately
  not_if   { File.exists?('/usr/local/bin/ruby-install') }
end

execute "install ruby-install-#{version}" do
  command <<-EOH.gsub(/^ {4}/, '')
    tar -xzvf ruby-install-#{version}.tar.gz
    cd ruby-install-#{version}
    make install
  EOH
  cwd    Chef::Config[:file_cache_path]
  action :nothing
end
