#
# Cookbook Name:: omnibus
# Recipe:: _cacerts
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

include_recipe 'omnibus::_bash'

#
# On FreeBSD the Ruby install's SSL points at `/etc/ssl/cert.pem` as the
# default root CA cert. This is actually the location of an optional symlink
# that the `ca_root_nss` port creates. We can't gurantee this optional
# symlink will exist so we'll just point `SSL_CERT_FILE` at the actual
# location of the root CA cert.
#
if freebsd?
  cacert_path = '/usr/local/share/certs/ca-root-nss.crt'

  omnibus_env['SSL_CERT_FILE'] << cacert_path

  file File.join(build_user_home, '.bashrc.d', 'cacerts.sh') do
    owner   node['omnibus']['build_user']
    group   node['omnibus']['build_user_group']
    mode    '0755'
    content <<-EOH.gsub(/^ {6}/, '')
      # This file is written by Chef for #{node['fqdn']}.
      # Do NOT modify this file by hand.

      export SSL_CERT_FILE=#{cacert_path}

    EOH
  end
end
