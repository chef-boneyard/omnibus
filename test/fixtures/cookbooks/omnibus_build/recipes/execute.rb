
include_recipe 'chef-sugar::default'

# There are issues on Mac OS X using the `omnibus_build` resource when
# the user executing the CCR and the `build_user` are not the same. This
# only happens when running things in Test Kitchen with the Vagrant driver
# so we'll just make the `build_user` "vagrant" in this scenerio.
if mac_os_x? && vagrant?
  node.set['omnibus']['build_user']          = 'vagrant'
  node.set['omnibus']['build_user_group']    = 'vagrant'
  node.set['omnibus']['build_user_password'] = 'vagrant'
end

include_recipe 'omnibus::default'

# clone Harmony project
harmony_project_dir = File.join(build_user_home, 'harmony')

# In order to have all the toolchain executables in the path, we need to set up
# the environment like load-omnibus-toolchain.sh does. This is a little hacky
# but we can't source the env like a shell does so this works.
ENV['PATH'] = "/opt/omnibus-toolchain/bin:#{ENV['PATH']}"

git harmony_project_dir do
  repository 'https://github.com/chef/omnibus-harmony.git'
  user node['omnibus']['build_user'] unless windows? # The git resource's user attribute doesn't play nice on Windows
  action :sync
end

omnibus_build 'harmony' do
  project_dir harmony_project_dir
  log_level :info
  config_overrides(
    append_timestamp: true
  )
end
