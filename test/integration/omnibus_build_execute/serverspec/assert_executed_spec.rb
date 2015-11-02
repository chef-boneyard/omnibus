require 'spec_helper'

def build_user
  if File.directory?(home_dir('vagrant'))
    'vagrant'
  else
    'omnibus'
  end
end

describe omnibus_build("#{build_user_home_dir}/harmony/pkg/harmony*.metadata.json") do
  it { should have_project('harmony') }
  it { should have_platform(omnibus_platform(os[:family])) }
  it { should have_platform_version(omnibus_platform_version(os[:family], os[:release])) }
  it { should have_arch(os[:arch]) }
  it { should have_package("#{build_user_home_dir}/harmony/pkg/#{subject.metadata['basename']}") }
end

%w(
  /var/cache/omnibus
  /opt/harmony
).each do |directory|
  describe file(directory) do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by(build_user) }
  end
end
