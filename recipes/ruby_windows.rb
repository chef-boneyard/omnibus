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

ruby_version = "1.9.3-p392"
ruby_filename = "rubyinstaller-#{ruby_version}.exe"
ruby_checksum = "7caa832b52873aaec3bc8da465e19196514149a7e3839a7882003fe80224e90d"

ruby_dir = "C:/Ruby193"
ruby_bindir = ::File.join(ruby_dir, "bin")
ruby_bin = ::File.join(ruby_bindir, "ruby.exe")

ruby_download_path = ::File.join(Chef::Config[:file_cache_path], ruby_filename)

remote_file ruby_download_path do
  source "http://cdn.rubyinstaller.org/archives/#{ruby_version}/#{ruby_filename}"
  checksum ruby_checksum
end

windows_batch "install Ruby #{ruby_version}" do
  code <<-EOB
"#{OmnibusHelper.win_friendly_path(ruby_download_path)}" ^
/silent ^
/dir="#{OmnibusHelper.win_friendly_path(ruby_dir)}" ^
/tasks="assocfiles"
EOB
  creates ruby_bin
end

windows_path OmnibusHelper.win_friendly_path(ruby_bindir) do
  action :add
end

#
# install the devkit
#
devkit_file = "DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"
devkit_checksum = "6c3af5487dafda56808baf76edd262b2020b1b25ab86aabf972629f4a6a54491"

devkit_dir = "C:/DevKit"

directory devkit_dir do
  action :create
end

remote_file ::File.join(devkit_dir, devkit_file) do
  source "https://github.com/downloads/oneclick/rubyinstaller/#{devkit_file}"
  checksum devkit_checksum
  not_if { ::File.exists?(::File.join(devkit_dir, devkit_file)) }
end

file ::File.join(devkit_dir, "config.yml") do
  content "- #{OmnibusHelper.win_friendly_path(ruby_dir)}"
end

windows_batch "install devkit" do
  code <<-EOB
#{devkit_file} -y
#{OmnibusHelper.win_friendly_path(ruby_bin)} dk.rb install
EOB
  cwd devkit_dir
  not_if { ::File.exists?(::File.join(devkit_dir, "dk.rb")) }
end

# Ensure a certificate authority is available and configured
# https://gist.github.com/fnichol/867550

cert_dir = ::File.join(ruby_dir, "ssl", "certs")
cacert_file = ::File.join(cert_dir, "cacert.pem")

directory cert_dir do
  recursive true
  action :create
end

remote_file cacert_file do
  source "http://curl.haxx.se/ca/cacert.pem"
  checksum "f5f79efd63440f2048ead91090eaca3102d13ea17a548f72f738778a534c646d"
  action :create
end

ENV['SSL_CERT_FILE'] = cacert_file

env "SSL_CERT_FILE" do
  value OmnibusHelper.win_friendly_path(cacert_file)
end

# Ensure Bundler is installed and available
gem_package "bundler" do
  version "1.3.5"
  gem_binary ::File.join(ruby_bindir, "gem")
end
