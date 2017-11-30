#
# Cookbook Name:: omnibus
# HWRP:: omnibus_build
#
# Copyright 2015, Chef Software, Inc.
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
require_relative 'helper'

class Chef
  class Resource::OmnibusBuild < Resource::LWRPBase
    resource_name :omnibus_build

    actions :execute
    default_action :execute

    attribute :project_name,
              kind_of: String,
              name_attribute: true
    attribute :project_dir,
              kind_of: String,
              required: true
    attribute :install_dir,
              kind_of: String,
              default: lazy { |r| Chef::Platform.windows? ? ::File.join(ENV['SYSTEMDRIVE'], r.project_name) : "/opt/#{r.project_name}" }
    attribute :base_dir,
              kind_of: String,
              default: lazy { Chef::Platform.windows? ? ::File.join(ENV['SYSTEMDRIVE'], 'omnibus-ruby') : '/var/cache/omnibus' }
    attribute :log_level,
              kind_of: Symbol,
              equal_to: [:internal, :debug, :info, :warn, :error, :fatal],
              default: :internal
    attribute :config_file,
              kind_of: String,
              default: lazy { |r| ::File.join(r.project_dir, 'omnibus.rb') }
    attribute :config_overrides,
              kind_of: Hash,
              default: {}
    attribute :expire_cache,
              kind_of: [TrueClass, FalseClass],
              default: false
    attribute :build_user,
              kind_of: String,
              default: lazy { |r| r.node['omnibus']['build_user'] }
    attribute :environment,
              kind_of: Hash,
              default: {}
    attribute :live_stream,
              kind_of: [TrueClass, FalseClass],
              default: false
  end

  class Provider::OmnibusBuild < Provider::LWRPBase
    include Omnibus::Helper

    provides :omnibus_build

    def whyrun_supported?
      true
    end

    action(:execute) do
      converge_by("execute #{new_resource}") do
        prepare_build_enviornment
        # bundle install
        execute_with_omnibus_toolchain(bundle_install_command)
        # omnibus build
        execute_with_omnibus_toolchain("bundle exec #{build_command}")
      end
    end

    protected

    def bundle_install_command
      if ::File.exist?(::File.join(new_resource.project_dir, 'Gemfile.lock'))
        'bundle install --without development --deployment'
      else
        'bundle install --without development --path vendor/bundle'
      end
    end

    def build_command
      [
        'omnibus',
        'build',
        new_resource.project_name,
        "--log-level #{new_resource.log_level}",
        "--config #{new_resource.config_file}",
        (new_resource.config_overrides.nil? || new_resource.config_overrides.empty?) ? '' : "--override #{new_resource.config_overrides.map { |k, v| "#{k}:#{v}" }.join(' ')}",
      ].join(' ')
    end

    def prepare_build_enviornment
      # Optionally wipe all caches (including the git cache)
      if new_resource.expire_cache
        cache = Resource::Directory.new(new_resource.base_dir, run_context)
        cache.recursive(true)
        cache.run_action(:delete)
      end

      # Clean up various directories from the last build
      %W(
        #{new_resource.base_dir}/build/#{new_resource.project_name}/*.manifest
        #{new_resource.base_dir}/pkg
        #{new_resource.project_dir}/pkg
        #{new_resource.install_dir}
      ).each do |directory|
        d = Resource::Directory.new(directory, run_context)
        d.recursive(true)
        d.run_action(:delete)
      end

      # Create required build directories with the correct ownership
      %W(
        #{new_resource.base_dir}
        #{new_resource.install_dir}
      ).each do |directory|
        d = Resource::Directory.new(directory, run_context)
        d.owner(new_resource.build_user)
        d.run_action(:create)
      end
    end

    def execute_with_omnibus_toolchain(command)
      execute = Resource::Execute.new("#{new_resource.project_name}: #{command}", run_context)
      execute.command(
        <<-CODE.gsub(/^ {10}/, '')
          . #{::File.join(build_user_home, 'load-omnibus-toolchain.sh')}
          #{command}
        CODE
      )
      execute.cwd(new_resource.project_dir)
      execute.environment(environment)
      execute.live_stream(new_resource.live_stream)
      execute.user(new_resource.build_user)
      execute.run_action(:run)
    end

    def environment
      environment = new_resource.environment.dup || {}
      # Ensure we inheriet the calling procceses $PATH
      environment['PATH'] = ENV['PATH']
      # We need to all underlying build process respect the build user
      # as specified by the `build_user` attribute.
      environment['USER']     = new_resource.build_user
      environment['USERNAME'] = new_resource.build_user
      environment['LOGNAME']  = new_resource.build_user
      # Ensure we don't inherit the $TMPDIR of the calling process. $TMPDIR
      # is set per user so we can hit permission issues when we execute
      # the build as a different user.
      environment['TMPDIR'] = nil if mac_os_x?
      environment
    end
  end

  class Provider::OmnibusBuildWindows < Provider::OmnibusBuild
    include Omnibus::Helper

    provides :omnibus_build, platform_family: 'windows'

    protected

    def execute_with_omnibus_toolchain(command)
      execute = Resource::Execute.new("#{new_resource.project_name}: #{command}", run_context)
      execute.command("call #{windows_safe_path_join(build_user_home, 'load-omnibus-toolchain.bat')} && #{command}")
      execute.cwd(new_resource.project_dir)
      execute.environment(new_resource.environment)
      execute.live_stream(new_resource.live_stream)
      execute.run_action(:run)
    end
  end
end
