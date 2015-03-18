#
# Cookbook Name:: omnibus
# Recipe:: _rsync
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

#
# TODO: Remove in Omnibus 4 and encourage the use of the +sync+ command instead!
#

# Include the common recipe
include_recipe 'omnibus::_common'

return if windows?
# Not needed on Sol 10
return if solaris_10?

include_recipe 'omnibus::_compile'

remote_install 'rsync' do
  source 'ftp://ftp.netbsd.org/pub/pkgsrc/distfiles/rsync-3.1.0.tar.gz'
  version '3.1.0'
  checksum '81ca23f77fc9b957eb9845a6024f41af0ff0c619b7f38576887c63fa38e2394e'
  build_command './configure'
  compile_command "make -j #{node.builders}"
  install_command 'make install'
  not_if { installed_at_version?('/usr/local/bin/rsync', '3.1.0') }
end

# Link /bin/rsync to our rsync, since some systems have their own rsync, but we
# will force our will on them!
link '/bin/rsync' do
  to '/usr/local/bin/rsync'
end
