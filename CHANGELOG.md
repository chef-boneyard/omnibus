omnibus Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the omnibus cookbook.

v2.6.9 (2015-07-03)
--------------------
# Bug fixes
- Remove omnibus-toolchain checksums

# Improvements
- Add recipe to install the windows sdk
- DRY up omnibus-toolchain installation logic

v2.6.8 (2015-06-22)
--------------------
# Bug fixes
- Install glibc-static on non-Power platforms running el-6 or higher

# Improvements
- Add path for 7-zip
- Added logic for installing variants of the omnibus toolchain

v2.6.7 (2015-06-03)
--------------------
# Bug fixes
- Update Perl path in FreeBSD git configure args

v2.6.6 (2015-06-03)
--------------------
# Bug fixes
- Install a known working version of Bundler

v2.6.5 (2015-06-01)
--------------------
# Improvements
- [ruby-windows] install a cacerts bundle that works with the S3 root cert

v2.6.4 (2015-05-01)
--------------------
# Improvements
- Updates to support RHEL/Ubuntu ppc64/le

v2.6.3 (2015-04-15)
--------------------
# Improvements
- Install the omnibus toolchain package if supported
- Don’t compile tools that ship in the omnibus-toolchain package
- Update to the latest TK with first-class Windows support!
- Add Solaris support to the `.kitchen.yml`
- Use ChefDK for all Travis testing
- Fix all Rubocop 0.28.0 style errors

v2.6.2 (2015-03-27)
--------------------
# Improvements
- Ensure all platforms have a sane `.gitconfig`
- Properly set Git’s CA bundle on Solaris 10

v2.6.1 (2015-03-23)
--------------------
# Improvements
- Add patch support to `ruby_install` resource
- Apply patch to Ruby source on Solaris 11 - this allows us to install Ruby 2.1.x.

v2.6.0 (2015-03-19)
--------------------
# Improvements
- Install glibc-static on EL6+
- Updated Solaris 10 build toolchain

v2.5.5 (2015-03-02)
--------------------
# Bug fixes
- Package signing on EL7 requires the rpm-sign package.

v2.5.4 (2015-03-01)
--------------------
# Bug fixes
- Don’t configure `SSL_CERT_FILE` globally on Windows

v2.5.3 (2015-02-27)
--------------------
# Improvements
- Solaris 11 support

# Bug fixes
-  Ruby install should not modify the PATH on Win systems

v2.5.2 (2015-02-05)
--------------------
# Improvements
- Update the url for ccache/rsync

v2.5.1 (2014-12-11)
--------------------
# Improvements
- Create `/etc/ssl/cert.pem` symlink on FreeBSD

v2.5.0 (2014-12-10)
--------------------
# Improvements
- Bump Ruby version to 2.1.5

v2.4.18 (2014-12-04)
--------------------
# Bug fixes
- Ensure FreeBSD Ruby install points at valid root CA cert

v2.4.16 (2014-11-11)
--------------------
# Bug fixes
- Fix CA bundle location for omnibus env on windows
- Upgrade Bash to 4.3.30 to fix [CVE-2014-6271] (Shellshock)

v2.4.14 (2014-11-06)
--------------------
# Bug fixes
- Don’t allow `ruby-install` to install deps

v2.4.12 (2014-10-24)
-------------------
# Bug fixes
- Configure BSD Make for backward compat mode
- Guarantee presence of bzip2 on RHEL

v2.4.10 (2014-10-22)
-------------------
# Bug fixes
- Ensure HTTPS remotes work in FreeBSD git install

v2.4.8 (2014-10-17)
-------------------
# Bug fixes
- Reintroduce `sign-rpm` script

v2.4.6 (2014-10-17)
-------------------
# Bug fixes
- Install ruby before git to ensure correct ownership of /usr/local/lib on OS X
- Stop infinitively growing Windows PATH

v2.4.4 (2014-10-15)
-------------------
# Bug fixes
- Disable DTrace integration when compiling Ruby

v2.4.2 (2014-10-14)
-------------------
# Bug fixes
- Use fully-qualified names when installing FreeBSD packages

# Improvement
- Add linting support (Foodcritic, Rubocop) to repo
- Fix ChefSpec 4.1.x deprecation warnings

v2.4.0 (2014-10-07)
-------------------
## Feature
- FreeBSD 10 support
- RHEL 7 support
- Ubuntu 14.04 support

## Improvement
- Update integration tests to ServerSpec 2
- Remove hard dependency on `yum-epel` cookbook
- RPM signing is now managed from Omnibus

v2.3.4 (2014-09-15)
-------------------
## Bug fixes
- Create environment scripts last.

## Improvement
- Add some additional elements to PATH on Windows systems.
- Print `gcc` and `make` versions in `load-omnibus-toolchain.bat`.

v2.3.2 (2014-09-05)
-------------------
## Improvement
- Install fakeroot and rpm-build packages on RHEL-based systems

v2.3.0 (2014-08-08)
-------------------
## Feature
- SUSE support

## Improvement
- Install fakeroot and devscripts packages on Debian-based systems

v2.2.0 (2014-06-19)
-------------------
## Improvement
- Fix the idempotency check for chruby
- Set SELinux to permissive
- Install rsync
- Update Chef Sugar to v2.0.0

v2.1.2 (2014-06-12)
-------------------
## Improvement
- Upgrade to ChefSpec 4
- Use the maximum number of builders when compiling from source

## Bug fixes
- Check `/usr/local/bin/bash` when checking if Bash is installed
- Bump default Ruby version to 2.1.2 to fix readline issues

v2.1.0 (2014-05-20)
-------------------
## Feature
- Platform-specific scripts to laod omnibus toolchain/environment
- Deploy `sign-rpm` script on RHEL platform family

## Improvement
- Add proper support for Windows
- Add a group for the build user

v2.0.2 (2014-04-07)
-------------------
- Fix memory leak in string concatenation

v2.0.0
------
## Improvement
- Add support for Mac OS X
- Update Rubocop
- Update to Berkshelf 3
- Reduce number of dependencies on community cookbooks
- Packaged custom ChefSpec matchers
- Added checksum verifications for installing remote packages
- Support multiple rubies with `ruby-install` and `chruby`
- Ensure a consistent version of bash everywhere by compiling from source
- Improved test suite and coverage
- Use a consistent version of git by compiling from source

## Breaking
- Dropped support for smartos
- Dropped support for solaris2

v1.2.4
------
## Improvement
- Pessimistically lock deps to `MAJOR.MINOR`
- Update to `git` cookbook `~> 3.0`
- Switch to using the `yum-epel` cookbook

v1.2.2
------
## Improvement
- Change default Ruby to 1.9.3-p484 (addresses [CVE-2013-4164])
- Refactor recipe to install Ruby on Windows. Main change is using
  `*.7zip` package instead of `*.msi`.
- Update .kitchen.yml for final 1.0 format.

v1.2.0
-------
## Feature
- Install Ruby using rbenv

## Improvement
- Add serverspec integration test coverage
- Add Foodcritic and Rubocop linting support
- Add Travis CI support
- Add FreeBSD to `.kitchen.yml`

v1.1.0
-------
## Feature
- Add `ccache` support for faster builds.

v1.0.10
-------
### Bug
- **[COOK-3178](https://tickets.opscode.com/browse/COOK-3178)** - Fix order of git installation on FreeBSD

v1.0.8
------
- [COOK-3170] Linking make to gmake breaks the package provider on FreeBSD

v1.0.6
------
- [CHEF-3151] Fix regression in /tmp/portsnap call

v1.0.4
------
- [CHEF-3151] Don't extract ports every time in omnibus::freebsd

v1.0.2
------
- [CHEF-2576] add support for SmartOS
- [CHEF-4141] Initial Freebsd support for omnibus

v1.0.0
------
- Initial release!
