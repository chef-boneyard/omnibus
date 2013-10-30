#
# Cookbook Name:: omnibus
# Recipe:: ccache
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

# Set up ccache, to speed up subsequent compilations.

ccache_tarball = File.join(Chef::Config[:file_cache_path], "ccache-3.1.9.tar.gz")

remote_file ccache_tarball do
  source "http://samba.org/ftp/ccache/ccache-3.1.9.tar.gz"
  mode "0644"
  not_if { File.exists?("/usr/local/bin/ccache") }
end

script "compile ccache" do
  interpreter 'sh'
  code <<-EOH
cd #{Chef::Config[:file_cache_path]}
tar zxvf ccache-3.1.9.tar.gz
cd ccache-3.1.9
./configure
make
make install
EOH
  not_if { File.exists?("/usr/local/bin/ccache") }
end

[ "gcc", "g++", "cc", "c++" ].each do |compiler|
  link "/usr/local/bin/#{compiler}" do
    to "/usr/local/bin/ccache"
  end
end
