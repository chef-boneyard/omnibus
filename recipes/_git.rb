#
# Cookbook Name:: omnibus
# Recipe:: _git
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

# Ensure every platform has a sane .gitconfig
file File.join(build_user_home, '.gitconfig') do
  owner   node['omnibus']['build_user']
  group   node['omnibus']['build_user_group']
  mode    '0644'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    [user]
      ; Set a sane user name and email. This makes git happy and prevents
      ; spammy output on each git command.
      name  = Omnibus
      email = omnibus@chef.io
    [color]
      ; Since this is a build machine, we do not want colored output.
      ui = false
    [core]
      editor = $EDITOR
      whitespace = fix
    [apply]
      whitespace = fix
    [push]
      default = tracking
    [branch]
      autosetuprebase = always
    [pull]
      rebase = preserve
  EOH
end

# Provided by the omnibus-toolchain package
unless windows?

  # We need to configure the omnibus-toolchain's embedded git to use
  # ca bundle that ships in the package. This can most likely be fixed by
  # a well placed `./configure` option when compiling git.
  #
  execute "/opt/#{node['omnibus']['toolchain_name']}/bin/git config --global http.sslCAinfo /opt/#{node['omnibus']['toolchain_name']}/embedded/ssl/certs/cacert.pem" do
    environment(
      'HOME' => build_user_home
    )
    user node['omnibus']['build_user']
  end

  ENV['GIT_SSL_CAINFO'] = "/opt/#{node['omnibus']['toolchain_name']}/embedded/ssl/certs/cacert.pem"

  return
end
