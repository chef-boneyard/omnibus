omnibus Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the omnibus cookbook.

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
