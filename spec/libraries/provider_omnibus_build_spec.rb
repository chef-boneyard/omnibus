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

describe Chef::Provider::OmnibusBuild do
  subject { Chef::Provider::OmnibusBuild.new(resource, run_context) }

  let(:build_user) { 'some_user' }
  let(:build_user_home) { "/home/#{build_user}" }
  let(:project_dir) { '/tmp/harmony' }
  let(:config_overrides) {}
  let(:expire_cache) { false }
  let(:live_stream) { false }
  let(:environment) do
    {
      'FOO' => 'BAR',
    }
  end

  let(:node) { stub_node(platform: 'ubuntu', version: '16.04') }

  let(:run_context) { Chef::RunContext.new(node, {}, nil) }
  let(:resource) do
    r = Chef::Resource::OmnibusBuild.new('harmony', run_context)
    r.project_dir(project_dir)
    r.environment(environment)
    r.config_overrides(config_overrides)
    r.expire_cache(expire_cache)
    r.live_stream(live_stream)
    r.build_user(build_user)
    r
  end

  before do
    allow(subject).to receive(:build_user_home).and_return(build_user_home)
  end

  describe '#bundle_install_command' do
    it 'excludes the development group' do
      expect(subject.send(:bundle_install_command)).to match(/--without development/)
    end

    context 'a Gemfile.lock exists' do
      before do
        expect(File).to receive(:exist?).with("#{project_dir}/Gemfile.lock").and_return(true)
      end

      it 'bundles with deployment mode' do
        expect(subject.send(:bundle_install_command)).to match(/--deployment/)
      end
    end

    context 'no Gemfile.lock file exists' do
      before do
        expect(File).to receive(:exist?).with("#{project_dir}/Gemfile.lock").and_return(false)
      end

      it 'bundles into a vendored path' do
        expect(subject.send(:bundle_install_command)).to match(%r{--path vendor\/bundle})
      end
    end
  end

  describe '#omnibus_build_command' do
    it 'defaults to an omnibus config file in the project directory' do
      expect(subject.send(:build_command)).to match(%r{--config #{project_dir}\/omnibus.rb})
    end

    it 'defaults to a log level of `internal`' do
      expect(subject.send(:build_command)).to match(/--log-level internal/)
    end

    it 'does not have an override CLI option' do
      expect(subject.send(:build_command)).to_not match(/--override/)
    end

    context 'config overrides are set' do
      let(:config_overrides) do
        {
          append_timestamp: false,
          use_git_caching: false,
        }
      end

      it 'translates the config_overrides hash to a CLI option' do
        expect(subject.send(:build_command)).to match(/--override append_timestamp:false use_git_caching:false/)
      end
    end
  end

  describe '#prepare_build_enviornment' do
    let(:directory_resource) do
      double(
        Chef::Resource::Directory, recursive: nil,
                                   owner: nil,
                                   run_action: nil
      )
    end

    before do
      allow(Chef::Resource::Directory).to receive(:new).and_return(directory_resource)
    end

    it 'cleans up directories from the previous build' do
      expect(directory_resource).to receive(:recursive).with(true).exactly(4).times
      expect(directory_resource).to receive(:run_action).with(:delete).exactly(4).times
      subject.send(:prepare_build_enviornment)
    end

    it 'creates required build directories' do
      expect(directory_resource).to receive(:owner).with('some_user').exactly(2).times
      expect(directory_resource).to receive(:run_action).with(:create).exactly(2).times
      subject.send(:prepare_build_enviornment)
    end

    context 'expire_cache is true' do
      let(:expire_cache) { true }

      it 'cleans up all Omnibus caches (including git cache)' do
        expect(directory_resource).to receive(:recursive).with(true).exactly(5).times
        expect(directory_resource).to receive(:run_action).with(:delete).exactly(5).times
        subject.send(:prepare_build_enviornment)
      end
    end
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
        <<-EOH.gsub(/^ {10}/, '')
          . #{build_user_home}\/load-omnibus-toolchain.sh
          #{command}
        EOH
      )
      subject.send(:execute_with_omnibus_toolchain, command)
    end

    it 'executes the command in the project directory' do
      expect(execute_resource).to receive(:cwd).with(project_dir)
      subject.send(:execute_with_omnibus_toolchain, command)
    end

    it 'executes the command with the provided environment' do
      expect(execute_resource).to receive(:environment).with(hash_including(environment))
      subject.send(:execute_with_omnibus_toolchain, command)
    end

    it 'executes the command as the provided user' do
      expect(execute_resource).to receive(:user).with(build_user)
      subject.send(:execute_with_omnibus_toolchain, command)
    end

    context 'live_stream is true' do
      let(:live_stream) { true }

      it 'executes the command with live_stream enabled' do
        expect(execute_resource).to receive(:live_stream).with(live_stream)
        subject.send(:execute_with_omnibus_toolchain, command)
      end
    end
  end

  describe '#environment' do
    it 'uses the $PATH from the calling process' do
      expect(subject.send(:environment)['PATH']).to eq(ENV['PATH'])
    end

    it 'sets the appropriate environment variables to the configured build_user' do
      expect(subject.send(:environment)['USER']).to eq(build_user)
      expect(subject.send(:environment)['USERNAME']).to eq(build_user)
      expect(subject.send(:environment)['LOGNAME']).to eq(build_user)
    end

    context 'on Mac OS X' do
      let(:node) { stub_node(platform: 'mac_os_x', version: '10.12') }

      it 'unsets $TMPDIR' do
        expect(subject.send(:environment)['TMPDIR']).to be_nil
      end
    end
  end
end
