def fixture(name)
  cookbook "omnibus_#{name}", path: "test/fixtures/cookbooks/omnibus_#{name}"
end

source 'https://supermarket.chef.io'

metadata

cookbook 'chef-ingredient',
        github: 'chef-cookbooks/chef-ingredient',
        branch: 'master'

group :integration do
  cookbook 'apt'
  cookbook 'fancy_execute'
  cookbook 'freebsd'
  cookbook 'yum-epel'
  fixture 'build'
end
