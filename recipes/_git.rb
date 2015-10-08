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
      'PATH' => "/opt/#{node['omnibus']['toolchain_name']}/embedded/bin",
      'HOME' => build_user_home
    )
    user node['omnibus']['build_user']
  end

  return
elsif windows?
  windows_package 'Git version 1.9.0-preview20140217' do
    source 'https://github.com/msysgit/msysgit/releases/download/Git-1.9.0-preview20140217/Git-1.9.0-preview20140217.exe'
    checksum '22d2d3f43c8a3eb59820c50da81022e98d4df92c333dffaae1ae88aefbceedfc'
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

  if debian?
    package 'gettext'
    package 'libcurl4-gnutls-dev'
    package 'libexpat1-dev'
    package 'libz-dev'
    package 'perl-modules'
  elsif freebsd?
    package 'ftp/curl'
    package 'textproc/expat2'
    package 'devel/gettext'
    package 'archivers/libzip'
    # FreeBSD requires gmake instead of make
    make = 'gmake'
    configure_args << ' --enable-pthreads=-pthread' \
                      ' ac_cv_header_libcharset_h=no' \
                      ' --with-curl=/usr/local' \
                      ' --with-expat=/usr/local' \
                      ' --with-perl=/usr/local/bin/perl'
  elsif mac_os_x?
    package 'curl'
    package 'expat'
    package 'gettext'
    git_environment['CPPFLAGS'] = '-I/usr/local/opt/openssl/include' if node['platform_version'].satisfies?('>= 10.11')
  elsif rhel?
    package 'curl-devel'
    package 'expat-devel'
    package 'gettext-devel'
    package 'perl-ExtUtils-MakeMaker' if version(node['platform_version']).satisfies?('>= 6')
    package 'zlib-devel'
  elsif suse?
    package 'libcurl-devel'
    package 'libexpat-devel'
    package 'gettext-runtime'
    package 'zlib-devel'
  elsif solaris?
    make = 'gmake'
    git_environment['CC'] = 'gcc'
  end

  remote_install 'git' do
    source          'https://git-core.googlecode.com/files/git-1.9.0.tar.gz'
    checksum        'de3097fdc36d624ea6cf4bb853402fde781acdb860f12152c5eb879777389882'
    version         '1.9.0'
    build_command   "./configure #{configure_args}"
    compile_command "#{make} -j #{node.builders}"
    install_command "#{make} install"
    environment     git_environment
    not_if { installed_at_version?('git', '1.9.0') }
  end

end
