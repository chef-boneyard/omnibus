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
    def self.resource_name
      :ruby_install
    end

    actions :run
    default_action :run

    attribute :version, kind_of: String, name_attribute: true
    attribute :default, kind_of: [TrueClass, FalseClass]
  end

  class Provider::RubyInstall < Provider::LWRPBase
    def whyrun_supported?
      true
    end

    action :run do
      if ::File.directory?("/opt/rubies/ruby-#{version}")
        Chef::Log.debug("#{new_resource} installed - skipping")
      else
        converge_by("install #{new_resource}") do
          install
          set_as_default if new_resource.default

          # If we are in this block, the resource was updated
          new_resource.updated_by_last_action(true)
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
      ]
    end

    def install
      execute "install ruby-#{version}" do
        command "ruby-install ruby #{version} -- #{compile_flags.join(' ')}"
      end
    end

    def set_as_default
      bash "set ruby-#{version}" do
        command "chruby ruby-#{version}"
      end

      file '/etc/profile.d/ruby.sh' do
        content <<-EOH.gsub(/^ {10}/, '')
          if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
            chruby ruby-#{version}
          fi
        EOH
      end
    end
  end
end
