def fixture(name)
  cookbook "omnibus_#{name}", path: "test/fixtures/cookbooks/omnibus_#{name}"
end

source 'https://supermarket.chef.io'

metadata

group :integration do
  cookbook 'apt'
  cookbook 'freebsd'
  cookbook 'yum-epel'
  fixture 'build'
end
