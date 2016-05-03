#
# Cookbook Name:: omnibus
# Library:: helper
#
# Copyright 2013, Chef Software, Inc.
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

module Omnibus
  # Recipe Helpers
  module Helper
    def windows_safe_path_join(*args)
      ::File.join(args).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || File::SEPARATOR)
    end

    def build_user_home
      if node['omnibus']['build_user_home']
        node['omnibus']['build_user_home']
      elsif mac_os_x?
        File.join('/Users', node['omnibus']['build_user'])
      elsif windows?
        windows_safe_path_join(ENV['SYSTEMDRIVE'], node['omnibus']['build_user'])
      elsif solaris?
        File.join('/export/home', node['omnibus']['build_user'])
      else
        File.join('/home', node['omnibus']['build_user'])
      end
    end

    def build_user_shell
      if omnibus_toolchain_enabled?
        "/opt/#{node['omnibus']['toolchain_name']}/embedded/bin/bash"
      else
        '/usr/local/bin/bash'
      end
    end

    def omnibus_env
      node.run_state[:omnibus_env] ||= Hash.new { |hash, key| hash[key] = [] } # ~FC001
    end

    def omnibus_toolchain_enabled?
      # We don't have an omnibus toolchain for windows yet.
      !windows?
    end

    def windows_safe_path_expand(arg)
      ::File.expand_path(arg).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || File::SEPARATOR)
    end
  end
end

module Omnibus
  # Recipe Helpers
  module ResourceHelpers
    def bundle_install_command
      if ::File.exist?(::File.join(project_dir, 'Gemfile.lock'))
        'bundle install --without development --deployment'
      else
        'bundle install --without development --path vendor/bundle'
      end
    end

    def build_command
      [
        'omnibus',
        'build',
        project_name,
        "--log-level #{log_level}",
        overrides_string.to_s,
        "--config #{config_file}"
      ].join(' ')
    end

    def cmd_with_toolchain(command)
      if Chef::Platform.windows?
        "call #{windows_safe_path_join(build_user_home, 'load-omnibus-toolchain.bat')} && #{command}"
      else
        <<-CODE.gsub(/^ {10}/, '')
          . #{::File.join(build_user_home, 'load-omnibus-toolchain.sh')} ; #{command}
        CODE
      end
    end

    def overrides_string
      return '' if config_overrides.empty?
      '--override ' + config_overrides.map { |k, v| "#{k}:#{v}" }.join(' ')
    end
  end
end

# WHYYYYYYYY
Chef::Node.send(:include, Omnibus::Helper)
Chef::Recipe.send(:include, Omnibus::Helper)
Chef::Resource.send(:include, Omnibus::Helper)
