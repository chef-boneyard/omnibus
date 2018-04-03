#
# Copyright:: Copyright (c) 2012 Chef Software, Inc.
# License:: Apache License, Version 2.0
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

default['omnibus'].tap do |omnibus|
  omnibus['build_user']         = 'omnibus'
  omnibus['build_user_home']    = nil
  omnibus['install_dir']        = nil
  omnibus['toolchain_name']     = 'omnibus-toolchain'
  omnibus['toolchain_version']  = 'latest'
  omnibus['toolchain_channel']  = 'stable'

  if platform_family?('windows')
    omnibus['build_user_group'] = 'Administrators'
    omnibus['base_dir']         = windows_safe_path_join(ENV['SYSTEMDRIVE'], 'omnibus-ruby')
    omnibus['git_checksum']     = 'ade9f885220964ec190b5de6c6aa42857e00afc7b21827223807c857cce38a78'
  else
    omnibus['build_user_group'] = 'omnibus'
    omnibus['base_dir']         = '/var/cache/omnibus'
    omnibus['git_checksum']     = '34dfc06b44880df91940dc318a2d3c83b79e67b6f05319c7c71e94d30893636d'
  end

  # You should store this password in an encrypted data bag item and
  # override in your wrapper. We've set a default password here purely
  # for testing purposes.
  omnibus['build_user_password'] = if platform_family?('windows', 'mac_os_x')
                                     # Password must be clear-text on Windows and Mac OS X.
                                     'get0ntheBus'
                                   else
                                     # Per Chef's requirements on Unix systems, the password below is
                                     # hashed using the MD5-based BSD password algorithm 1. The plain
                                     # text version is 'get0ntheBus'.
                                     '$1$QTCj0tQy$C60hWNmo8wZo.ctvDSy9p/'
                                   end
end
