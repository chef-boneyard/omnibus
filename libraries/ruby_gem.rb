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
  class Resource::RubyGem < Resource::GemPackage
    def initialize(*args)
      super
      @resource_name = :ruby_gem
    end

    def gem_binary(arg = nil)
      set_or_return(:gem_binary, arg, kind_of: String, default: gem_bin)
    end

    def ruby(arg = nil)
      set_or_return(:ruby, arg, kind_of: String, required: true)
    end

    private

    def gem_bin
      "/opt/rubies/ruby-#{ruby}*/bin/gem"
    end
  end
end
