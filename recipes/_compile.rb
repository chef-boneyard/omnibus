#
# Cookbook Name:: omnibus
# Recipe:: _compile
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
# This recipe is used to install additional packages/utilities that are not
# included by default in the build-essential cookbook. In the long term, this
# recipe should just "go away" and the build-essential cookbook should become
# more awesome.
#
build_essential 'install compilation tools' unless windows?

if freebsd?
  # Ensuring BSD Make is executed with the `-B` option (backward-compat mode)
  # allows many pieces of software to compile without `gmake`. A full
  # explanation of FreeBSD Make's various options can be found here:
  #
  #   https://www.freebsd.org/cgi/man.cgi?query=make(1)&sektion=
  #
  ruby_block 'Configure BSD Make for backward compat mode' do
    block do
      file = Chef::Util::FileEdit.new('/etc/make.conf')
      file.insert_line_if_no_match(/\.MAKEFLAGS:/, '.MAKEFLAGS: -B')
      file.write_file
    end
    only_if { File.exist?('/etc/make.conf') }
  end
elsif mac_os_x?
  # Use homebrew as the default package manager on OSX. We cannot install homebrew
  # until AFTER we have installed the XCode command line tools via build-essential
  # node.set['homebrew']['owner']       = node['omnibus']['build_user']
  node.normal['homebrew']['auto-update'] = false
  include_recipe 'homebrew::default'

  # Ensure /usr/local/* are writable by the `staff` group
  %w(
    /usr/local
    /usr/local/bin
    /usr/local/etc
    /usr/local/lib
    /usr/local/share
  ).each do |dir|
    directory dir do
      group 'staff'
      mode  '0775'
      recursive true
      not_if { node['platform_version'].satisfies?('>= 10.11') }
    end
  end
elsif rhel?
  # Make sure tar is installed. It's missing from some CentOS Docker images:
  #
  #   https://github.com/CentOS/sig-cloud-instance-images/issues/4
  #
  package %w(tar bzip2)
elsif windows?
  node.default['seven_zip']['syspath'] = true
  include_recipe 'seven_zip::default'
end
