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

# Include the common recipe
include_recipe 'omnibus::_common'

# Install the omnibus toolchain so we have a shell
include_recipe 'omnibus::_omnibus_toolchain'

if windows? && vagrant?
  # If this is an ephemeral vagrant/test-kitchen instance, we relax the password
  # so that the default password "vagrant" can be used.
  powershell_script 'Disable password complexity requirements' do
    code <<-EOH
      secedit /export /cfg $env:temp/export.cfg
      ((get-content $env:temp/export.cfg) -replace ('PasswordComplexity = 1', 'PasswordComplexity = 0')) | Out-File $env:temp/export.cfg
      secedit /configure /db $env:windir/security/new.sdb /cfg $env:temp/export.cfg /areas SECURITYPOLICY
    EOH
  end
end

# If this is a fresh solaris 10 system, there will not be an /export/home
# directory, and useradd doesn't do recursive create with -m
directory '/export/home' do
  owner 'root'
  group 'root'
  action :create
  only_if { solaris_10? }
end

group "create #{node['omnibus']['build_user_group']} group" do
  group_name node['omnibus']['build_user_group']
  # The Window's group provider get's cranky if attempting to create a
  # built-in group.
  ignore_failure true if windows?
  # Don't remove existing members - in case this is a built-in group.
  append true
end

# Ensure '/usr/local/bin/bash' is added to acceptable shells list
execute 'chsec_login_shell' do
  command "chsec -f /etc/security/login.cfg -s usw -a 'shells=/bin/sh,/bin/bsh,/bin/csh,/bin/ksh,/bin/tsh,/bin/ksh93,/usr/bin/sh,/usr/bin/bsh,/usr/bin/csh,/usr/bin/ksh,/usr/bin/tsh,/usr/bin/ksh93,/usr/bin/rksh,/usr/bin/rksh93,/usr/sbin/uucp/uucico,/usr/sbin/sliplogin,/usr/sbin/snappd,/usr/bin/bash,#{build_user_shell}'"
  only_if { aix? }
end

user node['omnibus']['build_user'] do
  home     build_user_home
  password node['omnibus']['build_user_password']
  unless windows?
    shell build_user_shell
    gid   node['omnibus']['build_user_group']
  end
  action :create
end

group node['omnibus']['build_user_group'] do
  members node['omnibus']['build_user']
  append true
  action :modify
  ignore_failure true if windows? # Cannot modify a group that doesn't exist
end

# Ensure the build user's home directory exists
if windows?
  # Home directory creation on Windows is a mess. If a user's home is set to
  # the default location (e.g C:\Users\<USER>) then Chef cannot create the
  # directory because of permission issues (see CHEF-5264). The good news is
  # Windows will automaticlally create the directory BUT only after the user
  # has logged in the first time! We can force this behavior by executing a
  # trival command as the build user.
  if build_user_home.include?(windows_safe_path_join(ENV['SYSTEMDRIVE'], 'Users'))
    ruby_block 'create-build-user-home' do
      block do
        whoami = Mixlib::ShellOut.new('whoami.exe', user: node['omnibus']['build_user'], password: node['omnibus']['build_user_password'])
        whoami.run_command
      end
      action :run
      not_if { ::File.exist?(build_user_home) }
    end
  else
    directory build_user_home do
      owner node['omnibus']['build_user']
      group node['omnibus']['build_user_group'] unless windows?
      action :create
    end
  end
else
  directory build_user_home do
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group'] unless windows?
    mode '0755'
    action :create
  end
end
