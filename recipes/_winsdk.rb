#
# Cookbook Name:: omnibus
# Recipe:: _winsdk
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

include_recipe "windows-sdk::windows_sdk"

program_files = ENV['ProgramFiles(x86)'] || ENV['ProgramFiles']
omnibus_env['PATH'] << windows_safe_path_join(program_files, 'Windows Kits', '8.1', 'bin', 'x64')
