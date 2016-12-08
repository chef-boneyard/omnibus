require 'spec_helper'

describe 'omnibus::_git' do
  context 'on all platforms' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'writes a sane git config' do
      expect(chef_run).to create_file('/home/omnibus/.gitconfig')
        .with_owner('omnibus')
        .with_mode('0644')
    end
  end

  context 'on platforms that use omnibus toolchain' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it "properly configures git's cacert" do
      expect(chef_run).to run_execute('/opt/omnibus-toolchain/bin/git config --global http.sslCAinfo /opt/omnibus-toolchain/embedded/ssl/certs/cacert.pem')
        .with_user('omnibus')
    end
  end
end
