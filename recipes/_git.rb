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

# Ensure our version is in sync with the Git cookbook so we don't install
# different versions during a single CCR. Eventually we will use the
# Git cookbook's resources/recipes directly but we'll need to update it
# to support some of the more esoteric platforms this cookbook supports.
node.set['git']['version']  = node['omnibus']['git_version']
node.set['git']['checksum'] = node['omnibus']['git_checksum']

# Provided by the omnibus-toolchain package
if omnibus_toolchain_enabled?

  # We need to configure the omnibus-build-essential's embedded git to use
  # ca bundle that ships in the package. This can most likely be fixed by
  # a well placed `./configure` option when compiling git. Follow this
  # issue for more details:
  #
  #  https://github.com/chef/omnibus-build-essential/issues/7
  #
  execute "git config --global http.sslCAinfo /opt/#{node['omnibus']['toolchain_name']}/embedded/ssl/certs/cacert.pem" do
    environment(
      'HOME' => build_user_home
    )
    user node['omnibus']['build_user']
  end

  ENV['GIT_SSL_CAINFO'] = "/opt/#{node['omnibus']['toolchain_name']}/embedded/ssl/certs/cacert.pem"

  return
elsif windows?

  windows_package "Git version #{node['omnibus']['git_version']}" do
    source "https://github.com/git-for-windows/git/releases/download/v#{node['omnibus']['git_version']}.windows.1/Git-#{node['omnibus']['git_version']}-32-bit.exe"
    checksum node['omnibus']['git_checksum']
    installer_type :inno
    action :install
  end

  # Git is installed to Program Files (x86) on 64-bit machines and
  # 'Program Files' on 32-bit machines
  program_files = ENV['ProgramFiles(x86)'] || ENV['ProgramFiles']

  git_paths = []
  git_paths << windows_safe_path_join(program_files, 'Git', 'Cmd')
  git_paths << windows_safe_path_join(program_files, 'Git', 'libexec', 'git-core')
  git_path = git_paths.join(File::PATH_SEPARATOR)

  windows_path git_path do
    action :add
  end

  omnibus_env['PATH'] << git_path
else
  include_recipe 'omnibus::_bash'
  include_recipe 'omnibus::_compile'
  include_recipe 'omnibus::_openssl'
  include_recipe 'omnibus::_user'

  make           = 'make'
  configure_args = '--prefix=/usr/local --without-tcltk'
  git_environment = { 'NO_GETTEXT' => '1' }

  if suse?
    package 'libcurl-devel'
    package 'libexpat-devel'
    package 'gettext-runtime'
    package 'zlib-devel'
  end

  remote_install 'git' do
    source          "https://www.kernel.org/pub/software/scm/git/git-#{node['omnibus']['git_version']}.tar.gz"
    checksum        node['omnibus']['git_checksum']
    version         node['omnibus']['git_version']
    build_command   "./configure #{configure_args}"
    compile_command "#{make} -j #{node.builders}"
    install_command "#{make} install"
    environment     git_environment
    not_if { installed_at_version?('/usr/local/bin/git', node['omnibus']['git_version']) }
  end
end
