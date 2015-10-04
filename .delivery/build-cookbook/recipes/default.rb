#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::default'

# Needed for cookbook publishing during `delivered/deploy`
chef_gem 'knife-supermarket' do
  compile_time false
  only_if { delivery_environment == 'delivered' }
  action :install
end
