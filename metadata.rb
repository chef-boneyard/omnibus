name              'omnibus'
maintainer        'Chef Software, Inc.'
maintainer_email  'releng@chef.io'
license           'Apache 2.0'
description       'Prepares a machine to be an Omnibus builder.'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '2.7.4'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'oracle'
supports 'redhat'
supports 'freebsd'
supports 'scientific'
supports 'mac_os_x'
supports 'suse'
supports 'ubuntu'
supports 'windows'
supports 'solaris2'

depends '7-zip',           '~> 1.0'
depends 'build-essential', '~> 2.0'
depends 'chef-sugar',      '~> 3.0'
depends 'homebrew',        '~> 1.9'
depends 'windows',         '~> 1.30'
depends 'wix',             '~> 1.1'
depends 'windows-sdk',     '~> 1.0'

source_url 'https://github.com/chef-cookbooks/omnibus' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/omnibus/issues' if respond_to?(:issues_url)
