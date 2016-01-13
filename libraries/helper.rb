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

require 'json'
require 'open-uri'

module Omnibus
  # Recipe Helpers
  module Helper
    def windows_safe_path_join(*args)
      ::File.join(args).gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || File::SEPARATOR)
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

    def build_user_shell
      if omnibus_toolchain_enabled?
        "/opt/#{node['omnibus']['toolchain_name']}/embedded/bin/bash"
      else
        '/usr/local/bin/bash'
      end
    end

    def omnibus_toolchain_enabled?
      # Currently we only build the Omnibus Toolchain for Solaris 10, AIX, and Nexus
      solaris_10? || aix? || nexus?
    end

    def toolchain_full_name
      node['omnibus']['toolchain_name'] + '-' + node['omnibus']['toolchain_version']
    end

    def etc_shells
      File.read('/etc/shells')
    rescue
      nil
    end

    def toolchain_url(toolchain_name = node['omnibus']['toolchain_name'])
      version        = node['omnibus']['toolchain_version']
      meta_bucket    = node['omnibus']['toolchain_meta_bucket']    # opscode-omnibus-package-metadata
      package_bucket = node['omnibus']['toolchain_package_bucket'] # opscode-omnibus-packages

      # unfortunately necessary as omni$vehicle doesn't align with ohai
      p = {
        os:               node['os'],
        platform_version: node['platform_version'],
        arch:             node['kernel']['machine']
      }

      case p[:arch]
      when 'i86pc'
        p[:arch] = 'i386'
      when 'sun4v'
        p[:arch] = 'sparc'
      end

      begin
        result = JSON.parse(open("https://#{meta_bucket}.s3.amazonaws.com/#{toolchain_name}-release-manifest/#{version}.json").read)

        relpath = result["#{p[:os]}"]["#{p[:platform_version]}"]["#{p[:arch]}"]["#{version}-1"]['relpath']
        "https://#{package_bucket}.s3.amazonaws.com" + relpath
      rescue JSON::ParserError
        message = "#{toolchain_full_name} isn't available on this platform!"

        # sadly #omnibus_toolchain_enabled? above doesn't work in chefspec
        if node['os'] == ('aix' || 'nexus')
          raise message
        elsif node['os'] == 'solaris2' && node['platform_version'] == '5.10'
          raise message
        else
          Chef::Log.warn("#{message} But it's okay.")
        end
      end
    end
  end
end

Chef::Node.send(:include, Omnibus::Helper)
Chef::Recipe.send(:include, Omnibus::Helper)
Chef::Resource.send(:include, Omnibus::Helper)
