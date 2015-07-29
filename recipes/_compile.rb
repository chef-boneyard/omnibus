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

return if windows?

#
# This recipe allows for custom yum repos to be specified on EL based platforms
#
include_recipe 'omnibus::_yum_repos' if rhel?

#
# This recipe is used to install additional packages/utilities that are not
# included by default in the build-essential cookbook. In the long term, this
# recipe should just "go away" and the build-essential cookbook should become
# more awesome.
#

include_recipe 'build-essential::default'

# Use homebrew as the default package manager on OSX. We cannot install homebrew
# until AFTER we have installed the XCode command line tools via build-essential
include_recipe 'homebrew::default' if mac_os_x?

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
elsif solaris_10?
  # This is ugly but we can't gurantee all tooling will respect the
  # `MAKE` enviroment variable.
  link '/usr/local/bin/make' do
    to '/usr/sfw/bin/gmake'
    only_if { File.exist?('/usr/sfw/bin/gmake') }
  end
end
