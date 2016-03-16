name              'omnibus'
maintainer        'Chef Software, Inc.'
maintainer_email  'releng@chef.io'
license           'Apache 2.0'
description       'Prepares a machine to be an Omnibus builder.'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '3.2.6'

supports 'amazon'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'freebsd'
supports 'mac_os_x'
supports 'oracle'
supports 'redhat'
supports 'scientific'
supports 'solaris2'
supports 'suse'
supports 'ubuntu'
supports 'windows'

depends 'build-essential', '>= 2.3.0'
depends 'chef-sugar', '>= 3.2.0'
depends 'git'
depends 'homebrew'
depends 'languages'
depends 'remote_install'
depends 'windows'
depends 'wix'
depends 'windows-sdk'

source_url 'https://github.com/chef-cookbooks/omnibus' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/omnibus/issues' if respond_to?(:issues_url)
