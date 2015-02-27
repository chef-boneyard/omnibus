source 'https://api.berkshelf.com'
metadata

group :integration do
  cookbook 'apt',      '~> 2.3'
  cookbook 'freebsd',  '~> 0.2'
  cookbook 'build-essential', github: 'opscode-cookbooks/build-essential',
                              branch: 'yzl/solaris'
  cookbook 'pkgutil', git: 'git@github.com:scotthain/pkgutil.git',
                      branch: 'yzl/providerize-everything'
  cookbook 'yum-epel',  '~> 0.3'
end
