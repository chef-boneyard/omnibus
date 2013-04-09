#
# Cookbook Name:: omnibus
# Recipe:: ruby_windows
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

ruby_filename = "rubyinstaller-1.9.3-p392.exe"
ruby_checksum = "7caa832b52873aaec3bc8da465e19196514149a7e3839a7882003fe80224e90d"

remote_file ::File.join(Chef::Config[:file_cache_path], ruby_filename) do
  source "http://cdn.rubyinstaller.org/archives/1.9.3-p392/#{ruby_filename}"
  checksum ruby_checksum
end

windows_batch "install ruby" do
  code "#{Chef::Config[:file_cache_path]}/#{ruby_name} /silent /dir=C:\\Ruby193 /tasks=\"assocfiles\""
  creates "C:\\Ruby193\\bin\\ruby.exe"
end

windows_path "C:\\Ruby193\\bin" do
  action :add
end

#
# install the devkit
#
kit_file = "DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"
kit_checksum = "6c3af5487dafda56808baf76edd262b2020b1b25ab86aabf972629f4a6a54491"

directory "C:\\DevKit" do
  action :create
end

remote_file "C:\\DevKit\\#{kit_file}" do
  source "https://github.com/downloads/oneclick/rubyinstaller/#{kit_file}"
  checksum kit_checksum
  not_if { File.exists?("C:\\DevKit\\#{kit_file}") }
end

file "C:\\DevKit\\config.yml" do
  content "- C:\\Ruby193"
end

windows_batch "install devkit" do
  code <<EOB
#{kit_file} -y
C:\\Ruby193\\bin\\ruby.exe dk.rb install
EOB
  cwd "C:\\DevKit"
end

gem_package "bundler" do
  version "1.3.5"
  gem_binary "C:\\Ruby193\\bin\\gem"
end
