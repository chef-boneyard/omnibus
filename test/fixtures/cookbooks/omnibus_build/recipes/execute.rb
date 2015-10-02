include_recipe 'omnibus::default'

# clone Harmony project
harmony_project_dir = File.join(build_user_home, 'harmony')

git harmony_project_dir do
  repository 'https://github.com/chef/omnibus-harmony.git'
  user node['omnibus']['build_user']
  action :sync
end

omnibus_build 'harmony' do
  project_dir harmony_project_dir
  log_level :internal
  config_overrides(
    append_timestamp: true
  )
end
