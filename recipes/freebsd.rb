#
# Cookbook Name:: omnibus
# Recipe:: freebsd
#
# Author:: Scott Sanders (ssanders@taximagic.com)
# Author:: Pete Cheslock (petecheslock@gmail.com)
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'freebsd::portsnap'

# COOK-3170: FreeBSD make breaks on some software when passed -j
ruby_block 'Disable make parallelization system-wide' do
  block do
    f = Chef::Util::FileEdit.new('/etc/make.conf')
    f.insert_line_if_no_match(/.MAKEFLAGS:/, <<-EOH

.MAKEFLAGS: -B
EOH
    )
    f.write_file
  end
  only_if { File.exists?('/etc/make.conf') }
end
