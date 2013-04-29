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

execute "Update Ports Tree" do
  command <<-EOS
    sed -e 's/\\[ ! -t 0 \\]/false/' /usr/sbin/portsnap > /tmp/portsnap
    chmod +x /tmp/portsnap
    /tmp/portsnap fetch extract
  EOS
end

include_recipe "build-essential"
include_recipe "git"

%w{
  gmake
  autoconf
  m4
}.each do |pkg|
  package pkg
end

link "/usr/local/bin/make" do
  to "/usr/local/bin/gmake"
end
