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

describe Chef::Provider::OmnibusBuildWindows do
  subject { Chef::Provider::OmnibusBuildWindows.new(resource, run_context) }

  let(:build_user) { 'some_user' }
  let(:build_user_home) { "C:\\Users\\#{build_user}" }
  let(:project_dir) { 'C:\build\harmony' }

  let(:node) { stub_node(platform: 'windows', version: '2012R2') }

  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:resource) do
    r = Chef::Resource::OmnibusBuild.new('harmony', run_context)
    r.project_dir(project_dir)
    r.build_user(build_user)
    r
  end

  before do
    allow(subject).to receive(:build_user_home).and_return(build_user_home)
  end

  describe '#execute_with_omnibus_toolchain' do
    let(:command) { 'ruby --version' }
    let(:execute_resource) do
      double(
        Chef::Resource::Execute, command: nil,
                                 cwd: nil,
                                 environment: nil,
                                 run_action: nil,
                                 user: nil,
                                 group: nil,
                                 live_stream: nil
      )
    end

    before do
      allow(Chef::Resource::Execute).to receive(:new).and_return(execute_resource)
    end

    it 'loads the omnbius toolchain from the build user home' do
      expect(execute_resource).to receive(:command).with(
        "call #{build_user_home}\\load-omnibus-toolchain.bat && #{command}"
      )
      subject.send(:execute_with_omnibus_toolchain, command)
    end
  end
end
