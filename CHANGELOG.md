omnibus Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the omnibus cookbook.

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
