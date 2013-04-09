#
# Cookbook Name:: omnibus
# Recipe:: solaris2
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

ENV['PATH'] = "/opt/csw/bin:/usr/local/bin:/usr/sfw/bin:/usr/ccs/bin:/usr/sbin:/usr/bin"

# TODO - Get this in the upstream `pkgutil` cookbook as an `opencsw` recipe.
bash "download and install pkgutil" do
  user "root"
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    echo "mail=
instance=overwrite
partial=nocheck
runlevel=nocheck
idepend=nocheck
rdepend=nocheck
space=nocheck
setuid=nocheck
conflict=nocheck
action=nocheck
basedir=default" > noask
    rm -f pkgutil.pkg
    wget http://mirror.opencsw.org/opencsw/pkgutil.pkg
    echo -e "all" | pkgadd -a noask -d pkgutil.pkg all
    pkgutil -U
  EOH
  not_if { ::File.exists?("/opt/csw/bin/pkgutil") }
end

%w{
  /usr/local
  /usr/local/bin
}.each do |dir|

  directory dir do
    owner  "root"
    group  "sys"
    mode   "0755"
    action :create
  end

end

cookbook_file "/etc/default/login" do
  source "default.login"
  user   "root"
  group  "sys"
  mode   "0444"
end

cookbook_file "/etc/default/su" do
  source "default.su"
  user   "root"
  group  "sys"
  mode   "0444"
end

# TODO - add solaris2 support to git cookbook
%w{
  git
  libxml2_dev
  libxslt_dev
  libssl_dev
  libyaml
  libtool
  help2man
  ggettext
  texinfo
}.each do |pkg|

  pkgutil_package pkg

end

%w{
  make
  tar
  install
  grep
  egrep
  fgrep
}.each do |bin|

  link "/opt/csw/bin/#{bin}" do
    to "/opt/csw/bin/g#{bin}"
  end

end

cookbook_file "/.profile" do
  source "root-profile"
  owner "root"
  group "root"
  mode "0600"
end
