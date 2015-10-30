require 'spec_helper'

describe 'omnibus::_ruby' do
  let(:chef_run) { ChefSpec::ServerRunner.converge(described_recipe) }

  it 'installs ruby' do
    expect(chef_run).to install_ruby_install('2.1.5')
  end
end
