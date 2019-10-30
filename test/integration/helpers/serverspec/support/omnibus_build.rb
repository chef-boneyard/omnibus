require 'json'

module Serverspec
  module Type
    # rubocop:disable Naming/PredicateName
    class OmnibusBuild < Base
      def initialize(metadata_pattern)
        @metadata_pattern = metadata_pattern
        @name = metadata_pattern
      end

      def has_project?(name)
        name == metadata['name']
      end

      def has_platform?(platform)
        platform == metadata['platform']
      end

      def has_platform_version?(platform_version)
        platform_version == metadata['platform_version']
      end

      def has_arch?(arch)
        arch == metadata['arch']
      end

      def has_package?(pacakge_path)
        ::File.exist?(pacakge_path)
      end

      def metadata
        return @metadata if @metadata

        metadata_file_content = ::File.read(Dir.glob(@metadata_pattern).first)

        @metadata = JSON.parse(metadata_file_content)
        @metadata
      end

      private

      def package
        return @package if @package

        @artifact = JSON.parse(response.body)
        @artifact
      end
    end
  end
end
