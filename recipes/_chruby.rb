#
# Cookbook Name:: omnibus
# Recipe:: _chruby
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
version = '0.3.8'

remote_file "#{Chef::Config[:file_cache_path]}/chruby-#{version}.tar.gz" do
  source   "https://github.com/postmodern/chruby/archive/v#{version}.tar.gz"
  notifies :run, "execute[install chruby-#{version}]", :immediately
  not_if   { File.exists?('/usr/local/bin/chruby-exec') }
end

execute "install chruby-#{version}" do
  command <<-EOH.gsub(/^ {4}/, '')
    tar -xzvf chruby-#{version}.tar.gz
    cd chruby-#{version}
    make install
  EOH
  cwd      Chef::Config[:file_cache_path]
  notifies :run, "bash[source chruby-#{version}]", :immediately
  action   :nothing
end

# Set the Ruby for the rest of this CCR (first-run)
bash "source chruby-#{version}" do
  command 'source /usr/local/share/chruby/chruby.sh'
  action  :nothing
end

# Load chruby on all future logins
file '/etc/profile.d/chruby.sh' do
  content <<-EOH.gsub(/^ {4}/, '')
    if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
      source /usr/local/share/chruby/chruby.sh
    fi
  EOH
end
