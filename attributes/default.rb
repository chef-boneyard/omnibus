#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

default['omnibus']['build_user'] = 'omnibus'
default['omnibus']['install_dir'] = '/opt/omnibus'
default['omnibus']['cache_dir'] = '/var/cache/omnibus'
default['omnibus']['ruby_version'] = '1.9.3-p484'

default['omnibus']['windows']['ruby_root'] = "#{ENV['SYSTEMDRIVE']}\\ruby"
default['omnibus']['windows']['ruby_checksum'] = '2dd1bfc4d48a5690480eea94a2b53450a39ef8f46f7d65f9e806485b0b2efdf5'
default['omnibus']['windows']['dev_kit_url'] = 'http://github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe'
default['omnibus']['windows']['dev_kit_checksum'] = '6c3af5487dafda56808baf76edd262b2020b1b25ab86aabf972629f4a6a54491'
