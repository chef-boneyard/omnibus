#
# Cookbook Name:: omnibus
# HWRP:: ruby_gem
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

class Chef
  class Resource::RubyGem < Resource::LWRPBase
    self.resource_name = :ruby_gem

    actions :install, :uninstall
    default_action :install

    attribute :ruby,    kind_of: String, required: true
    attribute :version, kind_of: String
  end
end

class Chef
  class Provider::RubyGem < Provider::LWRPBase
    require 'chef/mixin/shell_out'
    include Mixin::ShellOut
    include Omnibus::Helper

    action(:install) do
      if installed?
        Chef::Log.debug("#{new_resource} installed - skipping")
      else
        converge_by("Install #{new_resource}") do
          ruby_version_execute(install_command)
        end
      end
    end

    action(:uninstall) do
      if installed?
        converge_by("Install #{new_resource}") do
          ruby_version_execute(uninstall_command)
        end
      else
        Chef::Log.debug("#{new_resource} not installed - skipping")
      end
    end

    private

    #
    # Execute the command in the context of a certain Ruby version.
    #
    # @raise [Mixlib::ShellOut::ShellCommandFailed]
    #
    # @param [String] command
    #   the command to execute
    #
    # @return [String]
    #   the stdout from the command
    #
    def ruby_version_execute(command)
      if windows?
        prefixed_command = windows_safe_path_join(ENV['SYSTEMDRIVE'], 'rubies', new_resource.ruby, 'bin', command)
      else
        prefixed_command = "chruby-exec #{new_resource.ruby} -- #{command}"
      end
      shell_out!(prefixed_command).stdout
    end

    #
    # Determine if the given gem is installed.
    #
    # @return [true, false]
    #
    def installed?
      look  = new_resource.name
      look << " -v #{new_resource.version}" if new_resource.version

      ruby_version_execute("gem list --installed #{look}")
      true
    rescue Mixlib::ShellOut::ShellCommandFailed
      false
    end

    #
    # The command for installing the gem.
    #
    # @return [String]
    #
    def install_command
      command =  "gem install #{new_resource.name}"
      command << ' --no-ri --no-rdoc'
      command << " --version #{new_resource.version}" if new_resource.version
      command
    end

    #
    # The command for uninstalling the gem.
    #
    # @return [String]
    #
    def uninstall_command
      command = "gem uninstall #{new_resource.name}"

      if new_resource.version
        command << " --version #{new_resource.version}"
      else
        command << ' --all'
      end
    end
  end
end
