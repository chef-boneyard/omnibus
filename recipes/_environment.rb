#
# Cookbook Name:: omnibus
# Recipe:: _environment
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

# Include the common recipe
include_recipe 'omnibus::_common'

if windows?
  omni_path = omnibus_env.delete('PATH').uniq.join(File::PATH_SEPARATOR)
  # Get the install path of the omnibus-toolchain

  file windows_safe_path_join(build_user_home, 'load-omnibus-toolchain.bat') do
    content <<-EOH.gsub(/^ {6}/, '')
      @ECHO OFF

      REM ###############################################################
      REM # Load the base Omnibus environment
      REM ###############################################################

      set HOMEDRIVE=#{ENV['SYSTEMDRIVE']}
      set HOMEPATH=#{build_user_home.split(':').last}
      set PATH=#{omni_path};%PATH%
      set TOOLCHAIN_PATH="#{toolchain_path}"
      #{omnibus_env.map { |k, v| "set #{k}=#{v.first}" }.join("\n")}

      ECHO(
      ECHO ========================================
      ECHO = Environment
      ECHO ========================================
      ECHO(

      set

      REM ###############################################################
      REM # Query tool versions
      REM ###############################################################

      FOR /F "tokens=*" %%a in ('git --version') do SET GIT_VERSION=%%a
      FOR /F "tokens=*" %%a in ('ruby --version') do SET RUBY_VERSION=%%a
      FOR /F "tokens=*" %%a in ('gem --version') do SET GEM_VERSION=%%a
      FOR /F "tokens=*" %%a in ('bundle --version 2^> nul') do SET BUNDLER_VERSION=%%a
      FOR /F "tokens=*" %%a in ('gcc --version') do (
        SET GCC_VERSION=%%a
        GOTO :next
      )
      :next
      FOR /F "tokens=*" %%a in ('make --version') do (
        SET MAKE_VERSION=%%a
        GOTO :next
      )
      :next
      FOR /F "tokens=*" %%a in ('7z -h') do (
        SET SEVENZIP_VERSION=%%a
        GOTO :next
      )
      :next
      FOR /F "tokens=*" %%a in ('heat -help') do (
        SET WIX_HEAT_VERSION=%%a
        GOTO :next
      )
      :next
      FOR /F "tokens=*" %%a in ('candle -help') do (
        SET WIX_CANDLE_VERSION=%%a
        GOTO :next
      )
      :next
      FOR /F "tokens=*" %%a in ('light -help') do (
        SET WIX_LIGHT_VERSION=%%a
        GOTO :next
      )
      :next

      ECHO(
      ECHO(
      ECHO ========================================
      ECHO = Tool Versions
      ECHO ========================================
      ECHO(

      ECHO 7-Zip..........%SEVENZIP_VERSION%
      ECHO Bundler........%BUNDLER_VERSION%
      ECHO GCC............%GCC_VERSION%
      ECHO Git............%GIT_VERSION%
      ECHO Make...........%MAKE_VERSION%
      ECHO Ruby...........%RUBY_VERSION%
      ECHO RubyGems.......%GEM_VERSION%
      ECHO WiX:Candle.....%WIX_CANDLE_VERSION%
      ECHO WiX:Heat.......%WIX_HEAT_VERSION%
      ECHO WiX:Light......%WIX_LIGHT_VERSION%

      ECHO(
      ECHO ========================================

      @ECHO ON
    EOH
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group']
    sensitive true
  end

  file windows_safe_path_join(build_user_home, 'load-omnibus-toolchain.ps1') do
    content <<-EOH.gsub(/^ {6}/, '')

      ###############################################################
      # Load the base Omnibus environment
      ###############################################################

      $env:HOMEDRIVE="#{ENV['SYSTEMDRIVE']}"
      $env:HOMEPATH="#{build_user_home.split(':').last}"
      $env:TOOLCHAIN_PATH="#{toolchain_path}"
      $env:PATH="#{omni_path};$env:PATH"
      #{omnibus_env.map { |k, v| "$env:#{k}='#{v.first}'" }.join("\n")}

      Write-Host " ========================================"
      Write-Host " = Environment"
      Write-Host " ========================================"

      Get-ChildItem env:

      ###############################################################
      # Query tool versions
      ###############################################################

      $env:GIT_VERSION=git --version
      $env:RUBY_VERSION=ruby --version
      $env:GEM_VERSION=gem --version
      $env:BUNDLER_VERSION=bundle --version
      $env:GCC_VERSION=(gcc --version)[0]
      $env:MAKE_VERSION=(make --version)[0]
      $env:SEVENZIP_VERSION=(7z -h)[1]
      $env:WIX_HEAT_VERSION=(heat -help)[0]
      $env:WIX_CANDLE_VERSION=(candle -help)[0]
      $env:WIX_LIGHT_VERSION=(light -help)[0]

      Write-Host " ========================================"
      Write-Host " = Tool Versions"
      Write-Host " ========================================"

      Write-Host " 7-Zip..........$env:SEVENZIP_VERSION"
      Write-Host " Bundler........$env:BUNDLER_VERSION"
      Write-Host " GCC............$env:GCC_VERSION"
      Write-Host " Git............$env:GIT_VERSION"
      Write-Host " Make...........$env:MAKE_VERSION"
      Write-Host " Ruby...........$env:RUBY_VERSION"
      Write-Host " RubyGems.......$env:GEM_VERSION"
      Write-Host " WiX:Heat.......$env:WIX_HEAT_VERSION"
      Write-Host " WiX:Candle.....$env:WIX_CANDLE_VERSION"
      Write-Host " WiX:Light......$env:WIX_LIGHT_VERSION"

      Write-Host " ========================================"

    EOH
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group']
    sensitive true
  end
else

  omnibus_env['PATH'] << "/opt/#{node['omnibus']['toolchain_name']}/bin" if omnibus_toolchain_enabled?
  omnibus_env['PATH'] << '/usr/local/bin'

  if aix?
    omnibus_env['PATH'].unshift('/opt/IBM/xlC/13.1.0/bin:/opt/IBM/xlC/13.1.0/bin')
  elsif solaris_10?
    omnibus_env['PATH'] << '/usr/sfw/bin'
    omnibus_env['PATH'] << '/usr/ccs/bin'
  end

  omnibus_path = omnibus_env.delete('PATH').uniq.join(File::PATH_SEPARATOR)

  file ::File.join(build_user_home, 'load-omnibus-toolchain.sh') do
    content <<-EOH.gsub(/^ {6}/, '')
      #!/usr/bin/env bash

      ###################################################################
      # Load the base Omnibus environment
      ###################################################################
      export PATH="#{omnibus_path}:$PATH"
      #{omnibus_env.map { |k, v| "export #{k}=#{v.first}" }.join("\n")}

      echo ""
      echo "========================================"
      echo "= Environment"
      echo "========================================"
      echo ""

      env -0 | sort -z | tr '\\0' '\\n'

      ###################################################################
      # Query tool versions
      ###################################################################

      echo ""
      echo ""
      echo "========================================"
      echo "= Tool Versions"
      echo "========================================"
      echo ""

      echo "Bash.........$(bash --version | head -1)"
      echo "Bundler......$(bundle --version | head -1)"
      #{if aix?
          'echo "XLC..........$(xlc -qversion | head -1)"'
        elsif freebsd? && node['platform_version'].to_i <= 9
          'echo "GCC..........$(gcc49 --version | head -1)"'
        else
          'echo "GCC..........$(gcc --version | head -1)"'
        end}
      echo "Git..........$(git --version | head -1)"
      echo "Make.........$(make --version | head -1)"
      echo "Ruby.........$(ruby --version | head -1)"
      echo "RubyGems.....$(gem --version | head -1)"

      echo ""
      echo "========================================"
    EOH
    owner node['omnibus']['build_user']
    group node['omnibus']['build_user_group']
    mode '0755'
    sensitive true
  end
end
