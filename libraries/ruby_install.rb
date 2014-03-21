#
# Cookbook Name:: omnibus
# HWRP:: ruby_install
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
  class Resource::RubyInstall < Resource::LWRPBase
    self.resource_name = :ruby_install

    actions :install
    default_action :install

    attribute :version, kind_of: String, name_attribute: true
  end

  class Provider::RubyInstall < Provider::LWRPBase
    def whyrun_supported?
      true
    end

    action(:install) do
      if installed?
        Chef::Log.debug("#{new_resource} installed - skipping")
      else
        converge_by("install #{new_resource}") do
          install
        end
      end
    end

    protected

    def version
      new_resource.version
    end

    def compile_flags
      [
        '--disable-install-rdoc',
        '--disable-install-ri',
        '--with-out-ext=tcl',
        '--with-out-ext=tk',
      ].join(' ')
    end

    def install
      # Need to compile the command outside of the execute resource because
      # Ruby is bad at instance_eval
      install_command = "ruby-install ruby #{version} -- #{compile_flags}"

      execute = Resource::Execute.new("install ruby-#{version}", run_context)
      execute.command(install_command)
      execute.run_action(:run)
    end

    # Check if the given Ruby is installed by directory. If the full directory
    # does not exist, we can do partial global matching.
    #
    # @return [true, false]
    def installed?
      ::File.directory?("/opt/rubies/ruby-#{version}") ||
        Dir['/opt/rubies/ruby-*'].any? { |ruby| ruby.include?(version) }
    end
  end
end
