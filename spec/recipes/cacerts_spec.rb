require 'spec_helper'

describe 'omnibus::_cacerts' do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  context 'on freebsd' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'freebsd', version: '11.0')
                            .converge(described_recipe)
    end
  end
end
