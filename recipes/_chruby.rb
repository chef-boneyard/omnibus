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

include_recipe 'chef-sugar::default'
include_recipe 'build-essential::default'

remote_install 'chruby' do
  source 'https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz'
  version '0.3.8'
  checksum 'd980872cf2cd047bc9dba78c4b72684c046e246c0fca5ea6509cae7b1ada63be'
  install_command 'make install'
  not_if { installed_at_version?('chruby-exec', '0.3.8') }
end

# Load chruby on all future logins
file '/etc/profile.d/chruby.sh' do
  content <<-EOH.gsub(/^ {4}/, '')
    if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
      source /usr/local/share/chruby/chruby.sh
    fi
  EOH
end
