#
# Cookbook Name:: omnibus
# Extension:: node
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

class Chef::Node
  # The number of builders to use for make. By default, this is the total
  # number of CPUs, with a minimum being 2.
  def builders
    @builders ||= [node['cpu'] && node['cpu']['total'].to_i, 2].max
  end
end
