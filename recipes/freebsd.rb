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

include_recipe "build-essential"
include_recipe "git"

# The sed forces portsnap to run non-interactively
# fetch downloads a ports snapshot, extract puts them on disk (long)
# update will update an existing ports tree
portsnap_opts = ::File.exists?("/usr/ports") ? "update" : "fetch extract"
 
execute "Manage Ports Tree - #{portsnap_opts}" do
  command <<-EOS
    sed -e 's/\\[ ! -t 0 \\]/false/' /usr/sbin/portsnap > /tmp/portsnap
    chmod +x /tmp/portsnap #{portsnap_opts}
  EOS
end

# TODO - move these to build-essential
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

# Ensure /usr/local/bin is first in PATH
ruby_block "Ensure /usr/local/bin is first in PATH" do
  block do
    f = Chef::Util::FileEdit.new("/etc/profile")
    f.insert_line_if_no_match(/PATH/, <<-EOH

PATH=/usr/local/bin:$PATH
EOH
    )
    f.write_file
  end
  only_if { ::File.exists?("/etc/profile") }
end

ENV['PATH'] = "/usr/local/bin:#{ENV['PATH']}"
