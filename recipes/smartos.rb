#
# Cookbook Name:: omnibus
# Recipe:: smartos
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

execute "Update the pkgin database" do
  command "pkgin -y up"
end

# TODO - add smartos support to git cookbook
%w{
  autoconf
  binutils
  gcc47
  gmake
  libyaml
  libxml2
  libxslt
  pkg-config
  scmgit
}.each do |pkg|
  pkgin_package pkg
end
