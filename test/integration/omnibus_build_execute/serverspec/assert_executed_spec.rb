require 'spec_helper'

describe omnibus_build("#{home_dir}/harmony/pkg/harmony*.metadata.json") do
  it { should have_project('harmony') }
  it { should have_platform(os[:family]) }
  it { should have_platform_version(os[:release]) }
  it { should have_arch(os[:arch]) }
  it { should have_package("#{home_dir}/harmony/pkg/#{subject.metadata['basename']}") }
end

%w(
  /var/cache/omnibus
  /opt/harmony
).each do |directory|
  describe file(directory) do
    it { should exist }
    it { should be_directory }
    it { should be_owned_by 'omnibus' }
  end
end
