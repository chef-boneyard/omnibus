require 'spec_helper'

describe 'omnibus::_ruby' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'on platforms that do not use omnibus toolchain' do
    before(:each) do
      allow_any_instance_of(Chef::Recipe).to receive(:omnibus_toolchain_enabled?).and_return(false)
    end

    it 'installs ruby' do
      expect(chef_run).to install_ruby_install('2.1.5')
    end
  end
end
