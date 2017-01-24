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
    #
    # Convert the given path to be appropiate for shelling out on Windows.
    #
    # @param [String, Array<String>] pieces
    #   the pieces of the path to join and fix
    # @return [String]
    #   the path with applied changes
    #
    def windows_safe_path_join(*pieces)
      path = File.join(*pieces)

      if File::ALT_SEPARATOR
        path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
      else
        path
      end
    end

    def windows_safe_path_expand(arg)
      ::File.expand_path(arg).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || File::SEPARATOR)
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

    def omnibus_env
      node.run_state[:omnibus_env] ||= Hash.new { |hash, key| hash[key] = [] } # ~FC001
    end

    def toolchain_install_dir
      if windows?
        windows_safe_path_join(ENV['SYSTEMDRIVE'], 'opscode', node['omnibus']['toolchain_name'])
      else
        "/opt/#{node['omnibus']['toolchain_name']}"
      end
    end

    def build_user_shell
      if windows?
        windows_safe_path_join(toolchain_install_dir, 'embedded', 'bin', 'usr', 'bin', 'bash')
      else
        ::File.join(toolchain_install_dir, 'bin', 'bash')
      end
    end

    def windows_arch_i386?
      windows? && (i386? || (node.name =~ /i386/))
    end

    def mingw_toolchain_name
      windows_arch_i386? ? 'mingw32' : 'mingw64'
    end

    def mixlib_install_artifact_info_for(options)
      @toolchain_artifact_info ||= begin
        Chef::Recipe.send(:include, ChefIngredientCookbook::Helpers)
        ensure_mixlib_install_gem_installed!
        toolchain_options = Mixlib::Install.detect_platform
        toolchain_options.merge!(options)
        toolchain_options[:platform_version_compatibility_mode] = true
        Mixlib::Install.new(toolchain_options).artifact_info
      end
    end
  end
end

Chef::Node.send(:include, Omnibus::Helper)
Chef::Recipe.send(:include, Omnibus::Helper)
Chef::Resource.send(:include, Omnibus::Helper)
