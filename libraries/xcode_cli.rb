#
# Cookbook Name:: omnibus
# HWRP:: xcode_cli
#
# Author:: Yvonne Lam <yvonne@getchef.com>
#
# Copyright 2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
require 'mixlib/shellout'

class Chef
  class Resource::XcodeCli < Resource
    identity_attr :version

    attr_writer :exists

    def initialize(version, run_context = nil)
      super
      require 'chef-sugar' unless defined?(Chef::Sugar)

      # Set the resource name and provider
      @resource_name = :xcode_cli
      @provider = Provider::XcodeCli

      # Set default actions and allowed actions
      @action = :install
      @allowed_actions.push(:install)

      # Set the osx version
      @version = version
    end

    #
    # The osx version
    #
    # @param [String] arg
    # @return [String]
    #
    def version(arg = nil)
      set_or_return(:version, arg, kind_of: String)
    end

    #
    # Determine if xcode-cli is already installed.
    # This value is set by the provider when the current resource is loaded.
    #
    # @return [Boolean]
    #
    def exists?
      !!@exists
    end
  end
end

class Chef
  class Provider::XcodeCli < Provider
    def load_current_resource
      @current_resource ||= Chef::Resource::XcodeCli.new(new_resource.version)

      if current_xcode_install
        @current_resource.exists = true
        @current_resource.version(new_resource.version)
      end
    end

    #
    # This provider supports whyrun
    #
    def whyrun_supported?
      true
    end

    #
    # Install the xcode cli.
    #
    def action_install
      if @current_resource.exists?
        Chef::Log.info("xcode-cli #{new_resource} installed - skipping")
      else
        converge_by("Create xcode-cli #{new_resource}") do
          install_xcode_cli
        end
      end
    end

    private

    #
    #  Load the current resource
    #
    def current_xcode_install
      return @current_xcode_install if @current_xcode_install

      if Chef::Sugar::Constraints.version(new_resource.version).satisfies?('~> 10.9')
        cmd = 'pkgutil --pkg-info=com.apple.pkg.CLTools_Executables'
        command = Mixlib::ShellOut.new(cmd, timeout: 30)
        command.run_command
        command.stdout.strip

        return nil if command.status != 0

        @current_xcode_install = {
          version: new_resource.version,
        }
        @current_xcode_install
      end
    end

    #
    #  Execute a script
    #
    def execute(*pieces)
      command = pieces.join(' ')
      command = Mixlib::ShellOut.new(command, timeout: 120)
      command.run_command
      command.error!
      command.stdout.strip
    end

    #
    #  Install the Xcode CLI tools
    #
    def install_xcode_cli
      if Chef::Sugar::Constraints.version(new_resource.version).satisfies?('~> 10.9')
        bash_script = <<-EOF
          touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
          PROD=$(softwareupdate -l | grep -B 1 "Developer" | head -n 1 | awk -F"*" '{print $2}')
          softwareupdate -i $PROD -v
        EOF
        execute(bash_script)
      end
    end
  end
end
