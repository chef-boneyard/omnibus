#
# Cookbook Name:: omnibus
# Recipe:: ruby
#
# Copyright 2013, Chef Software, Inc.
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

version = node['omnibus']['ruby_version']

case node['platform_family']
when 'windows'
  include_recipe 'omnibus::ruby_windows'
else
  include_recipe 'omnibus::_chruby'
  include_recipe 'omnibus::_ruby_install'

  execute "install ruby-#{version}" do
    command "ruby-install ruby #{version}"
    notifies :run, "bash[set ruby-#{version}]", :immediately
    not_if { File.directory?("/opt/rubies/ruby-#{version}") }
  end

  # Set the Ruby for the rest of this CCR (first-run)
  bash "set ruby-#{version}" do
    command "chruby ruby-#{version}"
    action  :nothing
  end

  # Save the Ruby for all future logins
  file '/etc/profile.d/ruby.sh' do
    content <<-EOH.gsub(/^ {4}/, '')
      if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
        chruby ruby-#{version}
      fi
    EOH
  end

  gem_package 'bundler'
end
