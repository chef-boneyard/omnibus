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
    attribute :source_type,       kind_of: String, default: "gzip", :equal_to => ["tar", "gzip", "bz2"]
    attribute :version,           kind_of: String, required: true
    attribute :checksum,          kind_of: String, required: true
    attribute :patches,           kind_of: Array
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

    action(:install) do
      converge_by("Install #{new_resource}") do
        download
        verify
        extract
        patch
        build
        compile
        install
      end
    end

    protected

    def id
      @id ||= "#{new_resource.name}-#{new_resource.version}"
    end

    def label(name)
      @label ||= "#{name}[#{id}]"
    end

    def tarball_name
      @tarball_name ||= begin
        if (tarball_extension = new_resource.source.match(/\.tar\.bz2|\.tgz|\.tar\.gz|\.tar$/))
          @tarball_extension = tarball_extension.to_s
          ::File.basename(new_resource.source, tarball_extension.to_s)
        else
          @tarball_extension = default_extension
          id
        end
      end
    end

    def default_extension
      case new_resource.source_type
      when 'tar'
        "tar"
      when 'gzip'
        "tar.gz"
      when 'bz2'
        "tar.bz2"
      end
    end

    def tarball_extension
      tarball_name
      @tarball_extension
    end

    def cache_path
      @cache_path ||= ::File.join(Config[:file_cache_path], "#{id}.#{tarball_extension}")
    end

    def extract_path
      @extract_path ||= ::File.join(Config[:file_cache_path], tarball_name)
    end

    def download
      remote_file = Resource::RemoteFile.new(label('download'), run_context)
      remote_file.path(cache_path)
      remote_file.source(new_resource.source)
      remote_file.backup(false)
      remote_file.run_action(:create)
    end

    def verify
      require 'digest/sha2' unless defined?(Digest::SHA256)

      checksum = Digest::SHA256.file(cache_path).hexdigest

      raise ChecksumVerificationFailure.new(new_resource, checksum) unless new_resource.checksum == checksum
    end

    def extract_command
      case new_resource.source_type
      when 'tar'
        "tar -xvf"
      when 'gzip'
        "tar -zxvf"
      when 'bz2'
        "tar -jxvf"
      end
    end

    def extract
      execute = Resource::Execute.new(label('extract'), run_context)
      execute.command("#{extract_command} #{cache_path}")
      execute.cwd(Config[:file_cache_path])
      execute.run_action(:run)
    end

    def patch
      if new_resource.patches && !new_resource.patches.empty?
        execute = Resource::Execute.new(label('patch'), run_context)
        patch_cmds = new_resource.patches.map do |patch_file|
          "patch -p1 < #{patch_file}"
        end
        execute.command(patch_cmds.join(' && '))
        execute.cwd(::File.join(Config[:file_cache_path], id))
        execute.run_action(:run)
      end
    end

    %w(build compile install).each do |stage|
      class_eval <<-EOH, __FILE__, __LINE__ + 1
        def #{stage}
          return if new_resource.#{stage}_command.nil?

          execute = Resource::Execute.new(label('#{stage}'), run_context)
          execute.command(new_resource.#{stage}_command)
          execute.cwd(extract_path)
          execute.environment(new_resource.environment)
          execute.run_action(:run)
        end
      EOH
    end
  end
end
