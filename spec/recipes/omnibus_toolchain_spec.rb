require 'spec_helper'

describe 'omnibus::_omnibus_toolchain' do
  let(:json) do
    '{
      "aix": {
        "7.1": {
          "powerpc": {
            "1.1.3-1": {
              "relpath": "/aix/7.1/powerpc/bananas-1.1.3-1.powerpc.bff",
              "md5": "0a6f77b0245dab5f612da8c887cc50eb",
              "sha256": "330e509019341a730f81f9f7fe71b5e15f21bbbddb6a301417a86f11e5122876"
            }
          }
        }
      },
      "solaris2": {
        "5.10": {
          "sparc": {
            "1.1.3-1": {
              "relpath": "/solaris2/5.10/sparc/bananas-1.1.3-1.sparc.solaris",
              "md5": "cbda187dfac097efb974b4c8e0488ef6",
              "sha256": "bef7d0934c093b6b33a571ba0c94dcf05d01f55708765e9d8fc0a2a65ddd8ea5"
            }
          }
        }
      }
    }'
  end

  before do
    allow_any_instance_of(Chef::Node).to receive(:open).and_return(StringIO.new(json))
    allow_any_instance_of(Chef::Recipe).to receive(:open).and_return(StringIO.new(json))
    allow_any_instance_of(Chef::Resource).to receive(:open).and_return(StringIO.new(json))
  end

  context 'when run on AIX (7)' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'aix',
        version: '7.1',
        log_level: :info,
        file_cache_path: '/var/chef/cache') do |node|
          node.set['omnibus']['toolchain_name']    = 'bananas' # rubocop:disable IndentationWidth
          node.set['omnibus']['toolchain_version'] = '1.1.3'
      end.converge(described_recipe)
    end

    it 'downloads a toolchain BFF package' do
      expect(chef_run).to create_remote_file_if_missing('/var/chef/cache/bananas-1.1.3-1.powerpc.bff')
    end

    it 'installs the toolchain package' do
      expect(chef_run).to install_package('bananas').with(version: '1.1.3')
    end
  end

  context 'when run on Solaris (10)' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'solaris2',
        version: '5.10',
        log_level: :info,
        file_cache_path: '/var/chef/cache') do |node|
          node.set['omnibus']['toolchain_name']    = 'bananas' # rubocop:disable IndentationWidth
          node.set['omnibus']['toolchain_version'] = '1.1.3'
      end.converge(described_recipe)
    end

    it 'downloads a toolchain solaris package' do
      expect(chef_run).to create_remote_file_if_missing('/var/chef/cache/bananas-1.1.3-1.sparc.solaris')
    end

    it 'installs the toolchain package' do
      expect(chef_run).to install_package('bananas').with(version: '1.1.3')
    end
  end

  context 'when run on Ubuntu (14.04)' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu',
        version: '14.04',
        log_level: :debug,
        file_cache_path: '/var/chef/cache') do |node|
          node.set['omnibus']['toolchain_name']    = 'bananas' # rubocop:disable IndentationWidth
          node.set['omnibus']['toolchain_version'] = '1.1.3'
      end.converge(described_recipe)
    end

    it 'decides not to do anything' do
      expect(chef_run).to write_log('omnibus_toolchain_not_enabled')
    end
  end
end
