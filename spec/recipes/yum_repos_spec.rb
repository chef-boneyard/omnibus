require 'spec_helper'

describe 'omnibus::_yum_repos' do
  context 'on rhel' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'redhat', version: '6.5') do |node|
        node.set['omnibus']['yum_repos'] = {
          'test01' => {
            description: 'Test Repo',
            baseurl: 'http://test_repo.com',
            gpgcheck: true,
            gpgkey: 'http://test_repo.com/test-key',
          },
          'test02' => {
            description: 'Test Repo 2',
            baseurl: 'http://test_repo2.com',
          },
        }
      end.converge(described_recipe)
    end

    it 'includes _common' do
      expect(chef_run).to include_recipe('omnibus::_common')
    end

    it 'adds the test01 repository' do
      expect(chef_run).to create_yum_repository('test01')
    end

    it 'adds the test02 repository' do
      expect(chef_run).to create_yum_repository('test02')
    end
  end
end
