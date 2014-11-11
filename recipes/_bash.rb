#
# Cookbook Name:: omnibus
# Recipe:: _bash
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

return if windows?

include_recipe 'omnibus::_compile'

remote_install 'bash' do
  source 'http://ftp.gnu.org/gnu/bash/bash-4.3.30.tar.gz'
  version '4.3.30'
  checksum '317881019bbf2262fb814b7dd8e40632d13c3608d2f237800a8828fbb8a640dd'
  build_command './configure'
  compile_command "make -j #{node.builders}"
  install_command 'make install'
  not_if { installed_at_version?('/usr/local/bin/bash', '4.3.30') }
end

# Link /bin/bash to our bash, since some systems have their own bash, but we
# will force our will on them!
link '/bin/bash' do
  to '/usr/local/bin/bash'
end

#
# Create an .bashrc.d-style directory for arbitrary loading.
#
directory File.join(build_user_home, '.bashrc.d') do
  owner node['omnibus']['build_user']
  group node['omnibus']['build_user_group']
  mode  '0755'
end

#
# Write a .bash_profile that just loads .bashrc
#
file File.join(build_user_home, '.bash_profile') do
  owner   node['omnibus']['build_user']
  group   node['omnibus']['build_user_group']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # Source our bashrc
    if [ -f ~/.bashrc ]; then
      source ~/.bashrc
    fi
  EOH
end

#
# Load the regular profile
#
file File.join(build_user_home, '.bashrc') do
  owner   node['omnibus']['build_user']
  group   node['omnibus']['build_user_group']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # Source the system /etc/bashrc
    if [ -f /etc/bashrc ]; then
      source /etc/bashrc
    fi

    # Source all our .d files
    if [ -d ~/.bashrc.d ]; then
      for rc in ~/.bashrc.d/*; do
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
  group   node['omnibus']['build_user_group']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # The omnibus cookbook is very opinionated and puts all of it's things in
    # /usr/local/bin.
    export PATH="/usr/local/bin:$PATH"
  EOH
end
