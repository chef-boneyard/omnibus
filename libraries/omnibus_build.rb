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

module OmnibusCookbook
  class OmnibusBuild < Chef::Resource
    require_relative 'helper'

    resource_name :omnibus_build

    provides :omnibus_build

    property :project_name, String, name_property: true
    property :project_dir, String, required: true
    property :install_dir, String, default: lazy { default_install_dir }
    property :base_dir, String, default: lazy { default_base_dir }
    property :log_level, [:internal, :debug, :info, :warn, :error, :fatal], default: :internal
    property :config_file, String, default: lazy { default_config_file }
    property :config_overrides, Hash, default: {}
    property :expire_cache, [TrueClass, FalseClass], default: false
    property :build_user, String, default: lazy { node['omnibus']['build_user'] } # evil. leaving for back-compat. should be removed.
    property :environment, Hash, default: lazy { default_environment }

    # Enable why-run
    def whyrun_supported?
      true
    end

    #######################################
    # helpers for default property settings
    #######################################
    def default_install_dir
      Chef::Platform.windows? ? ::File.join(ENV['SYSTEMDRIVE'], project_name) : "/opt/#{project_name}"
    end

    def default_base_dir
      Chef::Platform.windows? ? ::File.join(ENV['SYSTEMDRIVE'], 'omnibus-ruby') : '/var/cache/omnibus'
    end

    def default_config_file
      ::File.join(project_dir, 'omnibus.rb')
    end

    def default_environment
      {
        'PATH' => ENV['PATH'],
        'USER' => build_user,
        'USERNAME' => build_user,
        'LOGNAME' => build_user,
        'TMPDIR' => nil
      }
    end

    include Omnibus::Helper
    include Omnibus::ResourceHelpers

    ################
    # Action seciton
    ################

    action :execute do
      converge_by("building #{name}") do
        #####
        # prepare_build_enviornment
        #####

        # Optionally wipe all caches (including the git cache)
        if new_resource.expire_cache
          directory new_resource.base_dir.to_s do
            recursive true
            action :delete
          end
        end

        # Clean up various directories from the last build
        %W(
          #{base_dir}/build/#{project_name}/*.manifest
          #{base_dir}/pkg
          #{project_dir}/pkg
          #{install_dir}
        ).each do |d|
          directory "#{d} removal" do
            path d
            recursive true
            action :delete
          end
        end

        # Create required build directories with the correct ownership
        %W(
          #{base_dir}
          #{install_dir}
        ).each do |d|
          directory "#{d} creation" do
            path d
            owner build_user
            action :create
          end
        end

        #####
        # bundle install
        #####
        execute "#{project_name}: bundle install" do
          command cmd_with_toolchain(bundle_install_command)
          cwd project_dir
          environment new_resource.environment
          user build_user
          action :run
        end

        #####
        # omnibus build
        #####
        execute "#{project_name}: bundle exec build_command" do
          command cmd_with_toolchain("bundle exec #{build_command}")
          cwd project_dir
          environment new_resource.environment
          user build_user
          action :run
        end
      end
    end
  end
end
