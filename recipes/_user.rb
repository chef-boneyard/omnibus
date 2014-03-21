#
# Cookbook Name:: omnibus
# Recipe:: _user
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

user node['omnibus']['build_user'] do
  home     build_user_home
  shell    '/bin/bash'
  action   :create
end

directory build_user_home do
  owner node['omnibus']['build_user']
  mode '0755'
end

#
# Create an .bashrc.d-style directory for arbitrary loading.
#
directory File.join(build_user_home, '.bashrc.d') do
  owner node['omnibus']['build_user']
  mode '0755'
end

#
# Write a .bash_profile that just loads .bashrc
#
file File.join(build_user_home, '.bash_profile') do
  owner   node['omnibus']['build_user']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # Source our bashrc
    if [ -f $HOME/.bashrc ]; then
      source $HOME/.bashrc
    fi
  EOH
end

#
# Load the regular profile
#
file File.join(build_user_home, '.bashrc') do
  owner   node['omnibus']['build_user']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # Source the system /etc/bashrc
    if [ -f /etc/bashrc ]; then
      source /etc/bashrc
    fi

    # Source all our .d files
    if [ -d $HOME/.bashrc.d ]; then
      for rc in $HOME/.bashrc.d/*; do
        test -f "$rc" || continue
        test -x "$rc" || continue
        source "$rc"
      done
    fi
  EOH
end

#
# We fully control the $PATH for the omnibus build user.
#
file File.join(build_user_home, '.bashrc.d', 'omnibus-path.sh') do
  owner   node['omnibus']['build_user']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # The omnibus cookbook is very opinionated and puts all of it's things in
    # /usr/local/bin.
    export PATH="/usr/local/bin:$PATH"
  EOH
end

#
# Automatically load our Ruby for the omnibus user.
#
file File.join(build_user_home, '.bashrc.d', 'chruby-default.sh') do
  owner   node['omnibus']['build_user']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # Automatically set the ruby version for the omnibus user
    chruby #{node['omnibus']['ruby_version']}
  EOH
end
