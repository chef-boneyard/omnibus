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

include_recipe 'chef-sugar::default'
return if windows?

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
end

file '/usr/local/bin/chruby-exec' do
  content <<-EOH.gsub(/^ {4}/, '')
    #!/usr/bin/env bash

    #
    # The version of `chruby-exec` that ships in `chruby` 0.3.8 does not work
    # under non-login shells as it assumes `/etc/profile.d/chruby.sh` loaded
    # the `chruby` function. This file was inspired by the following un-merged
    # PR that fixes the issue:
    #
    # https://github.com/postmodern/chruby/pull/250/files
    #

    case "$1" in
      -h|--help)
        echo "usage: chruby-exec RUBY [RUBYOPTS] -- COMMAND [ARGS...]"
        exit
        ;;
      -V|--version)
        echo "chruby version $CHRUBY_VERSION"
        exit
        ;;
    esac

    if (( $# == 0 )); then
      echo "chruby-exec: RUBY and COMMAND required" >&2
      exit 1
    fi

    argv=()

    for arg in $@; do
      shift

      if [[ "$arg" == "--" ]]; then break
      else                          argv+=($arg)
        fi
    done

    if (( $# == 0 )); then
      echo "chruby-exec: COMMAND required" >&2
      exit 1
    fi

    if ! command -v chruby > /dev/null; then
      command="source ${0%/*}/../share/chruby/chruby.sh && chruby $argv && $*"
    else
      command="chruby $argv && $*"
    fi

    if [[ -t 0 ]]; then exec bash -i -l -c "$command"
    else                exec bash    -l -c "$command"
    fi
  EOH
  mode '0755'
end

#
# Automatically load our Ruby for the omnibus user.
#
file File.join(build_user_home, '.bashrc.d', 'chruby-default.sh') do
  owner   node['omnibus']['build_user']
  group   node['omnibus']['build_user_group']
  mode    '0755'
  content <<-EOH.gsub(/^ {4}/, '')
    # This file is written by Chef for #{node['fqdn']}.
    # Do NOT modify this file by hand.

    # Load chruby
    if ! command -v chruby > /dev/null; then
      source /usr/local/share/chruby/chruby.sh
    fi

    # Automatically set the ruby version for the omnibus user
    chruby #{node['omnibus']['ruby_version']}
  EOH
end
