require_relative '../helpers/spec_helper'

def build_user
  if mac_os_x? && File.directory?(home_dir('vagrant'))
    'vagrant'
  else
    'omnibus'
  end
end

def omnibus_directories
  dirs = []
  dirs << omnibus_base_dir
  dirs << "#{omnibus_base_dir}/build"
  dirs << "#{omnibus_base_dir}/cache"
  dirs << "#{omnibus_base_dir}/pkg"
  dirs << "#{omnibus_base_dir}/src"
  if windows?
    dirs << 'C:/harmony'
  else
    '/opt/harmony'    
  end
  dirs
end

omnibus_directories.each do |dir|
  describe file(dir) do
    its('type') { should eq :directory }
    it { should be_directory }
  end
end

# describe omnibus_build("#{build_user_home_dir}/harmony/pkg/harmony*.metadata.json") do
#   it { should have_project('harmony') }
#   it { should have_platform(omnibus_platform(os[:family])) }
#   it { should have_package("#{build_user_home_dir}/harmony/pkg/#{subject.metadata['basename']}") }
#   #
#   # Specinfra does not return values for `os[:release]` and `os[:arch]`
#   # on Windows
#   # See the following for more details:
#   #
#   #   https://github.com/mizzy/specinfra/blob/4744735b6cc8aeed7fe8adcb312a3e72032465db/lib/specinfra/helper/os.rb#L20
#   #
#   unless windows?
#     it { should have_platform_version(omnibus_platform_version(os[:family], os[:release])) }
#     it { should have_arch(os[:arch]) }
#   end
# end
