#
# Cookbook Name:: omnibus
# Recipe:: _bash
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

include_recipe 'chef-sugar::default'
include_recipe 'build-essential::default'

remote_install 'bash' do
  source 'http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz'
  version '4.3'
  checksum 'afc687a28e0e24dc21b988fa159ff9dbcf6b7caa92ade8645cc6d5605cd024d4'
  build_command './configure'
  compile_command 'make'
  install_command 'make install'
  not_if { installed_at_version?('bash', '4.3') }
end

link '/bin/bash' do
  to '/usr/local/bin/bash'
end
