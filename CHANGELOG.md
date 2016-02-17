omnibus Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the omnibus cookbook.

v3.2.5
------
- Use build-essential cookbook to setup windows nodes to build ruby.

v3.2.4
------
- Support for ios_xr platform.

v3.2.3
------
- Don’t manage the build user’s home

v3.2.2
------
- Don’t override `HOME` during `omnibus_build` execution
- Ensure we use the

v3.2.1
------
- `omnibus_buld` - Exclude the `development` group when bundle installing

v3.2.0
------
- Sort env & tool list on all platforms.
- Enable omnibus toolchain for nexus platform
- Properly detect if the Toolchain is installed at a particular version

v3.1.4
------
- 'build_user_shell' is not longer a node attribute

v3.1.3
------
- Ensure all configured compilers appear on current CCR $PATH

v3.1.2
------
- Properly point `git` compile at homebrew-installed `curl`
- Ensure omnibus-toolchain is available on current CCR $PATH
- Configure `GIT_SSL_CAINFO` for current CCR
- Set build user shell to Omnibus Toolchain bash for all supported platforms
- Don’t set `/usr/local` ownership on recent OS X

v3.1.1
------
- prepend xlc to PATH on AIX

v3.1.0
------
# Feature
- AIX support

v3.0.0
------

# New Features

* Make Git version a configurable option; Bump default version to 2.6.2.
* Add Docker support to Test Kitchen config (used in Travis testing).

# Improvements

* Remove `chruby`
* Remove `rsync`
* Remove `ccache`
* Update `ruby_install` usage.
* Depend on `remote_install` cookbook and remove duplicate resource.
* `omnibus_build` resource - Ensure all underlying build processes respect `build_user`.
* Remove pessimistic locking in cookbook deps - This makes it easier to integrate this cookbook onto nodes with large run lists.
* Make the `install_dir` attribute optional.
* Rename `cache_dir` attribute to the proper `base_dir` (this matches the naming we use everywhere else).
* Ensure `tar` is installed on EL.
* Ensure Homebrew directories have the correct group ownership on Mac OS X.
* Complete integration test coverage (ServerSpec) for FreeBSD, Mac OS X and Windows (yes the tests work on Windows).
* Suppress Ruby warnings when running tests on Travis.
* Converge and execute all integration tests on Travis against Debian, Ubuntu and CentOS.

v2.7.7
------
- Fix Windows detection on older Chef versions

v2.7.6
------
- Bump the version pin on the wix cookbook.  We now depend on Wix 3.10 features.

v2.7.5
------
- Move ruby_install to the languages cookbook and vendor from there.

v2.7.4
------
- Create a separate Windows-specific OmnibusBuild provider

v2.7.3
------
- Added Windows support to the `omnibus_build` resource

v2.7.2
------
- Properly include chef-sugar in the `build-cookbook::deploy`.

v2.7.1
------
- Publish updates to the chef-server.delivery.chef.co

v2.7.0
------
# Feature
- Added `omnibus_build` resource

v2.6.13
-------
# Bug fixes
- `File::ALT_SEPARATOR` can be nil

# Improvements
- Stop creating symlinks in /usr/bin - We can use load-omnibus-toolchain.sh to set the `PATH` correctly
- Use bash built by this cookbook for login shell

v2.6.12
-------
# Improvements
- Ship our own version of cacerts

v2.6.11
-------
# Improvements
- Fix all rubocop errors

v2.6.10
-------
# Bug fixes
- Fix fakeroot recipe to remove obsolete resource attributes

v2.6.9
------
# Bug fixes
- Remove omnibus-toolchain checksums

# Improvements
- Add recipe to install the windows sdk
- DRY up omnibus-toolchain installation logic

v2.6.8
------
# Bug fixes
- Install glibc-static on non-Power platforms running el-6 or higher

# Improvements
- Add path for 7-zip
- Added logic for installing variants of the omnibus toolchain

v2.6.7
------
# Bug fixes
- Update Perl path in FreeBSD git configure args

v2.6.6
------
# Bug fixes
- Install a known working version of Bundler

v2.6.5
------
# Improvements
- [ruby-windows] install a cacerts bundle that works with the S3 root cert

v2.6.4
------
# Improvements
- Updates to support RHEL/Ubuntu ppc64/le

v2.6.3
------
# Improvements
- Install the omnibus toolchain package if supported
- Don’t compile tools that ship in the omnibus-toolchain package
- Update to the latest TK with first-class Windows support!
- Add Solaris support to the `.kitchen.yml`
- Use ChefDK for all Travis testing
- Fix all Rubocop 0.28.0 style errors

v2.6.2
------
# Improvements
- Ensure all platforms have a sane `.gitconfig`
- Properly set Git’s CA bundle on Solaris 10

v2.6.1
------
# Improvements
- Add patch support to `ruby_install` resource
- Apply patch to Ruby source on Solaris 11 - this allows us to install Ruby 2.1.x.

v2.6.0
------
# Improvements
- Install glibc-static on EL6+
- Updated Solaris 10 build toolchain

v2.5.5
------
# Bug fixes
- Package signing on EL7 requires the rpm-sign package.

v2.5.4
------
# Bug fixes
- Don’t configure `SSL_CERT_FILE` globally on Windows

v2.5.3
------
# Improvements
- Solaris 11 support

# Bug fixes
-  Ruby install should not modify the PATH on Win systems

v2.5.2
------
# Improvements
- Update the url for ccache/rsync

v2.5.1
------
# Improvements
- Create `/etc/ssl/cert.pem` symlink on FreeBSD

v2.5.0
------
# Improvements
- Bump Ruby version to 2.1.5

v2.4.18
-------
# Bug fixes
- Ensure FreeBSD Ruby install points at valid root CA cert

v2.4.16
-------
# Bug fixes
- Fix CA bundle location for omnibus env on windows
- Upgrade Bash to 4.3.30 to fix [CVE-2014-6271] (Shellshock)

v2.4.14
-------
# Bug fixes
- Don’t allow `ruby-install` to install deps

v2.4.12
-------
# Bug fixes
- Configure BSD Make for backward compat mode
- Guarantee presence of bzip2 on RHEL

v2.4.10
-------
# Bug fixes
- Ensure HTTPS remotes work in FreeBSD git install

v2.4.8
------
# Bug fixes
- Reintroduce `sign-rpm` script

v2.4.6
------
# Bug fixes
- Install ruby before git to ensure correct ownership of /usr/local/lib on OS X
- Stop infinitively growing Windows PATH

v2.4.4
------
# Bug fixes
- Disable DTrace integration when compiling Ruby

v2.4.2
------
# Bug fixes
- Use fully-qualified names when installing FreeBSD packages

# Improvement
- Add linting support (Foodcritic, Rubocop) to repo
- Fix ChefSpec 4.1.x deprecation warnings

v2.4.0
------
## Feature
- FreeBSD 10 support
- RHEL 7 support
- Ubuntu 14.04 support

## Improvement
- Update integration tests to ServerSpec 2
- Remove hard dependency on `yum-epel` cookbook
- RPM signing is now managed from Omnibus

v2.3.4
------
## Bug fixes
- Create environment scripts last.

## Improvement
- Add some additional elements to PATH on Windows systems.
- Print `gcc` and `make` versions in `load-omnibus-toolchain.bat`.

v2.3.2
------
## Improvement
- Install fakeroot and rpm-build packages on RHEL-based systems

v2.3.0
------
## Feature
- SUSE support

## Improvement
- Install fakeroot and devscripts packages on Debian-based systems

v2.2.0
------
## Improvement
- Fix the idempotency check for chruby
- Set SELinux to permissive
- Install rsync
- Update Chef Sugar to v2.0.0

v2.1.2
------
## Improvement
- Upgrade to ChefSpec 4
- Use the maximum number of builders when compiling from source

## Bug fixes
- Check `/usr/local/bin/bash` when checking if Bash is installed
- Bump default Ruby version to 2.1.2 to fix readline issues

v2.1.0
------
## Feature
- Platform-specific scripts to laod omnibus toolchain/environment
- Deploy `sign-rpm` script on RHEL platform family

## Improvement
- Add proper support for Windows
- Add a group for the build user

v2.0.2
------
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
