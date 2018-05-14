#
# Copyright 2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Chef::Resource::OmnibusBuild do
  subject { Chef::Resource::OmnibusBuild.new(project_name, run_context) }
  let(:node) { stub_node(platform: 'ubuntu', version: '16.04') }
  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:build_user) { 'morty' }
  let(:project_dir) { "/home/#{build_user}/#{project_name}" }
  let(:project_name) { 'meeseeks' }

  it 'has a default base_dir' do
    expect(subject.base_dir).to eq('/var/cache/omnibus')
  end

  it 'has a default install_dir based on the project name' do
    expect(subject.install_dir).to eq("/opt/#{project_name}")
  end

  it 'has a default config_file based on the project_dir' do
    subject.project_dir(project_dir)
    expect(subject.config_file).to eq(File.join(project_dir, 'omnibus.rb'))
  end

  it 'has a default build_user based on node attributes' do
    node.override['omnibus']['build_user'] = build_user
    expect(subject.build_user).to eq(build_user)
  end

  context 'on Windows' do
    let(:project_dir) { "C:/Users/#{build_user}/#{project_name}" }

    before do
      allow(ENV).to receive(:[]).with('SYSTEMDRIVE').and_return('C:')
      allow(ChefConfig).to receive(:windows?).and_return(true)
    end

    it 'has a Windowsy default base_dir' do
      expect(subject.base_dir).to eq('C:/omnibus-ruby')
    end

    it 'has a Windowsy default install_dir based on the project name' do
      expect(subject.install_dir).to eq("C:/#{project_name}")
    end

    it 'has a Windowsy default config_file based on the project_dir' do
      subject.project_dir(project_dir)
      expect(subject.config_file).to eq(File.join(project_dir, 'omnibus.rb'))
    end
  end
end
