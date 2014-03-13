require 'spec_helper'

describe 'omnibus::_compile' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'includes build-esssential' do
    expect(chef_run).to include_recipe('build-essential::default')
  end
end
