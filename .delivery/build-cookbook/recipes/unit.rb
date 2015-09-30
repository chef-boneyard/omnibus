#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

# Ensure chef-sugar is installed for ChefSpec tests
include_recipe 'chef-sugar::default'

include_recipe 'delivery-truck::unit'
