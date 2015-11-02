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
  omnibus['ruby_version']       = '2.1.5'
  omnibus['toolchain_name']     = 'omnibus-toolchain'
  omnibus['toolchain_version']  = '0.0.1'

  if platform_family == 'windows'
    omnibus['build_user_home']  = windows_safe_path_join(ENV['SYSTEMDRIVE'], 'omnibus')
    omnibus['build_user_group'] = 'Administrators'
    omnibus['install_dir']      = windows_safe_path_join(ENV['SYSTEMDRIVE'], 'omnibus', 'build')
    omnibus['cache_dir']        = windows_safe_path_join(ENV['SYSTEMDRIVE'], 'cache', 'omnibus')
  else
    omnibus['build_user_home']  = nil
    omnibus['build_user_group'] = 'omnibus'
    omnibus['install_dir']      = '/opt/omnibus'
    omnibus['cache_dir']        = '/var/cache/omnibus'
  end

  # You should store this password in an encrypted data bag item and
  # override in your wrapper. We've set a default password here purely
  # for testing purposes.
  if platform_family == 'windows' || platform_family == 'mac_os_x'
    # Passsword must be clear-text on Windows and Mac OS X.
    omnibus['build_user_password'] = 'get0ntheBus'
  else
    # Per Chef's requirements on Unix systems, the password below is
    # hashed using the MD5-based BSD password algorithm 1. The plain
    # text version is 'get0ntheBus'.
    omnibus['build_user_password'] = '$1$QTCj0tQy$C60hWNmo8wZo.ctvDSy9p/'
  end
end
