# require_relative '../helpers/spec_helper'

#######
# Linux
#######

describe user('omnibus') do
  it { should exist }
  its('shell') { should eq '/opt/omnibus-toolchain/embedded/bin/bash' }
end

describe command('/opt/omnibus-toolchain/embedded/bin/ruby --version') do
  its('exit_status') { should eq 0 }
end

describe command('/opt/omnibus-toolchain/embedded/bin/bash --version') do
  its('exit_status') { should eq 0 }
end

describe command('/opt/omnibus-toolchain/embedded/bin/git --version') do
  its('exit_status') { should eq 0 }
end

describe command("rm -rf /tmp/derp ; /opt/omnibus-toolchain/embedded/bin/git clone https://github.com/chef-cookbooks/omnibus.git /tmp/derp") do
  its('exit_status') { should eq 0 }
end

describe command("su - omnibus -l -c 'source ~/load-omnibus-toolchain.sh && which ruby'") do
  its('stdout') { should match %r{/opt/omnibus-toolchain/embedded/bin/ruby$} }
end

describe command("su - omnibus -l -c 'source ~/load-omnibus-toolchain.sh && echo $PATH'") do
  its('stdout') { should match %r{^/opt/omnibus-toolchain/embedded/bin(.+)} }
end

#####
# OSX
#####

#     describe 'Xcode Command Line Tools', if: mac_os_x? do
#       let(:pkg_receipt) do
#         if omnibus_platform_version(os[:family], os[:release]) == '10.8'
#           'com.apple.pkg.DeveloperToolsCLI'
#         else
#           'com.apple.pkg.CLTools_Executables'
#         end
#       end

#       it 'is installed' do
#         expect(command("pkgutil --pkg-info=#{pkg_receipt}").exit_status).to eq 0
#       end
#     end

#########
# Windows
#########

# describe 'Windows', if: windows? do
#   describe 'ruby' do
#     describe command('C:/languages/ruby/2.1.5/bin/ruby --version') do
#       its(:stdout) { should match '2.1.5' }
#     end

#     describe command('C:/languages/ruby/2.1.5/bin/bundle --version') do
#       its(:exit_status) { should eq 0 }
#     end
#   end

#   describe 'git' do
#     describe command('git --version') do
#       its(:stdout) { should match('2.6.2') }
#     end
#   end

#   describe 'WiX' do
#     let(:wix_version) { '3.10.0.2103' }

#     describe command('heat.exe -help') do
#       its(:stdout) { should match "Windows Installer XML Toolset Toolset Harvester version #{wix_version}" }
#     end

#     describe command('candle.exe -help') do
#       its(:stdout) { should match "Windows Installer XML Toolset Compiler version #{wix_version}" }
#     end

#     describe command('light.exe -help') do
#       its(:stdout) { should match "Windows Installer XML Toolset Linker version #{wix_version}" }
#     end
#   end

#   describe 'Windows SDK' do
#     describe command('signtool sign /?') do
#       # `signtool.exe` returns output over STDERR... *sigh*
#       its(:stderr) { should match 'Usage: signtool sign' }
#     end
#   end

#   describe '7-zip' do
#     describe command('7z -h') do
#       its(:stdout) { should match '9.22' }
#     end
#   end

#   describe 'environment' do
#     # We are using regular Ruby because ServerSpec existent checks are failing on Windows
#     describe omnibus_base_dir do
#       it 'exists' do
#         expect(File.directory?(omnibus_base_dir)).to be true
#       end
#     end

#     [
#       '.gitconfig',
#       'load-omnibus-toolchain.bat'
#     ].each do |env_file|
#       # We are using regular Ruby because ServerSpec existent checks are failing on Windows
#       describe env_file do
#         it 'exists' do
#           expect(File.exist?(File.join(build_user_home_dir, env_file))).to be true
#         end
#       end
#     end
#   end
# end
