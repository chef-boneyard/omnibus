#
# Cookbook Name:: omnibus
# Recipe:: _packaging
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

#
# This recipe is used to install the "packaging" components.
#

if debian?
  package %w(devscripts dpkg-dev ncurses-dev zlib1g-dev fakeroot binutils gnupg)
elsif freebsd?
  package 'devel/ncurses'
elsif rhel?
  package %w(ncurses-devel rpm-build zlib-devel)

  if node['platform_version'].satisfies?('>= 7')
    # EL 7 split rpm-sign into its own package:  http://cholla.mmto.org/computers/linux/rpm/signing.html
    package 'rpm-sign'
  elsif node['platform_version'].satisfies?('~> 6') && (ppc64? || ppc64le?)
    # EL 6 and later consider glibc-static optional: https://access.redhat.com/solutions/33868
    # The libhugetlbfs build (analytics) requires it.
    # See https://github.com/kaustubh-d/omnibus/commit/41b547817572a8a75d857cfc3562ca819f327761
    package 'glibc-static'
  end

  # This script makes unattended rpm signing possible!
  cookbook_file ::File.join(build_user_home, 'sign-rpm') do
    source 'sign-rpm'
    mode '0755'
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group']
    mode '0755'
  end
elsif windows?
  include_recipe 'wix::default'
  # Because of some really nasty path issues with the Windows 8.1 SDK installer, we're
  # not using the windows-sdk cookbook, and are installing it manually here instead :(
  # The main issue is if the installer itself is in a long filename directory (ie
  # C:\Users\Administrator\...) it will not install because it reads this as
  # C:\Users\ADMINI~1\... and this somehow mangles the download path...
  file_url = 'http://download.microsoft.com/download/B/0/C/B0C80BA3-8AD6-4958-810B-6882485230B5/standalonesdk/sdksetup.exe'
  file_path = ::File.join(Chef::Config[:file_cache_path], 'sdksetup.exe')

  remote_file file_path do
    source file_url
  end

  # Thankfully the installer is idempotent, so we don't need a guard on this.
  powershell_script 'convert_path_name' do
    cwd  Chef::Config[:file_cache_path]
    code '.\\sdksetup.exe /norestart /quiet /features OptionId.WindowsDesktopSoftwareDevelopmentKit'
  end

  omnibus_env['PATH'] << node['wix']['home']
  omnibus_env['PATH'] << node['seven_zip']['home']
  omnibus_env['PATH'] << windows_safe_path_join(ENV['ProgramFiles(x86)'] || ENV['ProgramFiles'], 'Windows Kits', '8.1', 'bin', 'x64')
end
