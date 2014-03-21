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

include_recipe 'omnibus::_bash'
include_recipe 'omnibus::_common'
include_recipe 'omnibus::_compile'

# Install chruby so we can easily manage rubies.
remote_install 'chruby' do
  source 'https://codeload.github.com/postmodern/chruby/tar.gz/v0.3.8'
  checksum 'd980872cf2cd047bc9dba78c4b72684c046e246c0fca5ea6509cae7b1ada63be'
  version '0.3.8'
  install_command 'make install'
  not_if { installed_at_version?('chruby-exec', '0.3.8') }
  notifies :run, 'execute[source_chruby]', :immediately
end

# Source chruby for the rest of this CCR
execute 'source_chruby' do
  command 'source /usr/local/share/chruby/chruby.sh'
  action  :nothing
end

# Source chruby all the time in the future
file '/etc/profile.d/chruby.sh' do
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
      source /usr/local/share/chruby/chruby.sh
      source /usr/local/share/chruby/auto.sh
    fi
  EOH
end
