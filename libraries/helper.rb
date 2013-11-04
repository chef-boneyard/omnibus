#
# Cookbook Name:: omnibus
# Library:: helper
#
# Copyright 2013, Opscode, Inc.
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

module Omnibus
  # Recipe Helpers
  module Helper

    # returns windows friendly version of the provided path,
    # ensures backslashes are used everywhere
    def win_friendly_path(path)
      path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR) if path
    end

    # Ensures $HOME is temporarily set to the given user. The original
    # $HOME is preserved and re-set after the block has been yielded
    # to.
    #
    # This is a workaround for CHEF-3940. TL;DR Certain versions of
    # `git` misbehave if configuration is inaccessible in $HOME.
    #
    # More info here:
    #
    #   https://github.com/git/git/commit/4698c8feb1bb56497215e0c10003dd046df352fa
    #
    def with_home_for_user(username, &block)

      time = Time.now.to_i

      ruby_block "set HOME for #{username} at #{time}" do
        block do
          ENV['OLD_HOME'] = ENV['HOME']
          ENV['HOME'] = begin
            require 'etc'
            Etc.getpwnam(username).dir
          rescue ArgumentError # user not found
            "/home/#{username}"
          end
        end
      end

      yield

      ruby_block "unset HOME for #{username} #{time}" do
        block do
          ENV['HOME'] = ENV['OLD_HOME']
        end
      end
    end
  end
end

Chef::Recipe.send(:include, Omnibus::Helper)
