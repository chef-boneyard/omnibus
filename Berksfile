def fixture(name)
  cookbook "omnibus_#{name}", path: "test/fixtures/cookbooks/omnibus_#{name}"
end

source 'https://supermarket.chef.io'

metadata

cookbook 'languages', git: 'https://github.com/chef-cookbooks/languages.git', branch: 'ruby_install'

group :integration do
  cookbook 'apt'
  cookbook 'fancy_execute'
  cookbook 'freebsd'
  cookbook 'yum-epel'
  fixture 'build'
end
