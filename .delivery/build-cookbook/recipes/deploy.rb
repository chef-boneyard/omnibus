#
# Cookbook Name:: build-cookbook
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'delivery-truck::deploy'

#
# We publish to supermarket.chef.io when a change hits delivered
#
# TODO: The following code needs to be incorporated into `delivery-truck`
#       in some manner.
#
if delivery_environment == 'delivered'
  require 'uri'
  include_recipe 'chef-sugar::default'

  supermarket_creds = DeliverySugar::ChefServer.new.with_server_config { encrypted_data_bag_item_for_environment('creds', 'supermarket') }
  supermarket_site  = 'https://supermarket.chef.io'
  supermarket_user  = supermarket_creds['username']
  supermarket_key   = ::File.join(node['delivery']['workspace']['cache'], "#{supermarket_user}@#{URI.parse(supermarket_site).host}.pem")
  cookbook_directory_supermarket = File.join(node['delivery']['workspace']['cache'], "cookbook-share")

  # Write API key to disk
  file supermarket_key do
    content supermarket_creds['pem']
    mode '0600'
    sensitive true
  end

  directory cookbook_directory_supermarket do
    recursive true
    # We delete the cookbook-to-share staging directory each time to ensure we
    # don't have out-of-date cookbooks hanging around from a previous build.
    action [:delete, :create]
  end

  changed_cookbooks.each do |cookbook|
    # Supermarket does not let you share a cookbook without a `metadata.rb`
    # then running `berks vendor` is not an option otherwise we will ended
    # up just with a `metadata.json`
    #
    # Lets link the real cookbook.
    link ::File.join(cookbook_directory_supermarket, cookbook.name) do
      to cookbook.path
    end

    execute "share_cookbook_to_supermarket_#{cookbook.name}" do
      command "knife supermarket share #{cookbook.name} " \
              "--user #{supermarket_user} " \
              "--key #{supermarket_key} " \
              "--supermarket-site #{supermarket_site} " \
              "--cookbook-path #{cookbook_directory_supermarket}"
      not_if "knife supermarket show #{cookbook.name} #{cookbook.version} " \
              "--user #{supermarket_user} " \
              "--key #{supermarket_key} " \
              "--supermarket-site #{supermarket_site}"
    end
  end
end
