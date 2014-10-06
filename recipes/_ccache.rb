#
# Cookbook Name:: omnibus
# Recipe:: _ccache
#
# Copyright 2013-2014, Chef Software, Inc.
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

# Include the common recipe
include_recipe 'omnibus::_common'

return if windows?

include_recipe 'omnibus::_bash'
include_recipe 'omnibus::_compile'

# Set up ccache, to speed up subsequent compilations.
remote_install 'ccache' do
  source 'http://samba.org/ftp/ccache/ccache-3.1.9.tar.gz'
  version '3.1.9'
  checksum 'a2270654537e4b736e437975e0cb99871de0975164a509dee34cf91e36eeb447'
  build_command './configure'
  compile_command "make -j #{node.builders}"
  install_command 'make install'
  not_if { installed_at_version?('ccache', '3.1.9') }
end

# FreeBSD 10+ uses clang
compilers = if freebsd? && node['platform_version'] =~ /10/
              %w(cc c++)
            else
              %w(gcc g++ cc c++)
            end

compilers.each do |compiler|
  link "/usr/local/bin/#{compiler}" do
    to '/usr/local/bin/ccache'
  end
end
