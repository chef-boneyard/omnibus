#
# Cookbook Name:: omnibus
# HWRP:: remote_install
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
  class Resource::RemoteInstall < Resource::LWRPBase
    self.resource_name = :remote_install

    actions :install
    default_action :install

    attribute :source,            kind_of: String, required: true
    attribute :version,           kind_of: String, required: true
    attribute :checksum,          kind_of: String, required: true
    attribute :build_command,     kind_of: String
    attribute :compile_command,   kind_of: String
    attribute :install_command,   kind_of: String, required: true
    attribute :environment,       kind_of: Hash,   default: {}
  end

  class Provider::RemoteInstall < Provider::LWRPBase
    class ChecksumVerificationFailure < RuntimeError
      def initialize(resource, actual)
        super <<-EOH
Verification for #{resource} failed due to a checksum mismatch:

  expected: #{resource.checksum}
  actual:   #{actual}

This added security check is used to prevent MITM attacks when downloading the
remote file. If you have updated the version or URL for the download, you will
also need to update the checksum value. You can find the checksum value on the
software publishers website.
EOH
      end
    end

    def whyrun_supported?
      true
    end

    action :install do
      converge_by("Install #{new_resource}") do
        download
        verify
        extract
        build
        compile
        install

        # It is the responsibility of the developer to use appropiate guards...
        new_resource.updated_by_last_action(true)
      end
    end

    protected

    def id
      @id ||= "#{new_resource.name}-#{new_resource.version}"
    end

    def label(name)
      @label ||= "#{name}[#{id}]"
    end

    def cache_path
      @cache_path ||= ::File.join(Chef::Config[:file_cache_path], "#{id}.tar.gz")
    end

    def extract_path
      @extract_path ||= ::File.join(Chef::Config[:file_cache_path], id)
    end

    def download
      remote_file label('download') do
        path   cache_path
        source new_resource.source
        backup false
      end
    end

    def verify
      ruby_block label('verify') do
        block do
          require 'digest/sha2' unless defined?(Digest::SHA256)
          checksum = Digest::SHA256.file(cache_path).hexdigest

          unless new_resource.checksum == checksum
            raise ChecksumVerificationFailure.new(new_resource, checksum)
          end
        end
      end
    end

    def extract
      execute label('extract') do
        command "tar -xzvf #{id}.tar.gz"
        cwd     Chef::Config[:file_cache_path]
      end
    end

    %w(build compile install).each do |stage|
      class_eval <<-EOH, __FILE__, __LINE__ + 1
        def #{stage}
          return if new_resource.#{stage}_command.nil?

          execute label('#{stage}') do
            command(new_resource.#{stage}_command)
            cwd(extract_path)
            environment(new_resource.environment)
          end
        end
      EOH
    end
  end
end
