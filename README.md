Description
===========

Prepares a machine to be an Omnibus builder.

Requirements
============

## Chef

Chef 11.0.0+

## Platform

Supported platforms by platform family:

* debian (debian, ubuntu)
* fedora
* rhel (centos, redhat, amazon, scientific etc.)
* solaris2
* windows

## Cookbooks

This cookbook depends on the following external cookbooks:

* [apt](http://community.opscode.com/cookbooks/apt) (Opscode)
* [build-essential](http://community.opscode.com/cookbooks/build-essential) (Opscode)
* [git](http://community.opscode.com/cookbooks/git) (Opscode)
* [homebrew](http://community.opscode.com/cookbooks/homebrew) (Opscode)
* [pkgutil](http://community.opscode.com/cookbooks/pkgutil) (marthag)
* [yum](http://community.opscode.com/cookbooks/yum) (Opscode)
* [wix](http://community.opscode.com/cookbooks/wix) (Opscode)
* [7-zip](http://community.opscode.com/cookbooks/7-zip) (Opscode)

Recipes
=======

The default recipe is the main entrypoint for the cookbook and does the
following:

* Ensures all required Omnibus-related directories are created and owned by the
build user.
* Ensures a sane build tool-chain is installed and configured (using the
[build-essential](http://community.opscode.com/cookbooks/build-essential)
cookbook)
* Ensures git is installed (using the
[git](http://community.opscode.com/cookbooks/git) cookbook)
* Includes a platform-specific recipe to apply additional tweaks as appropriate.

All other recipes should be treated as "private" and are not meant to be used
individually. They only exist to support the `default` recipe.

Attributes
==========

Attribute       | Description |Type | Default
----------------|-------------|-----|--------
build_user      | User Omnibus build will be performed as. | String  | omnibus
install_dir     | Installation directory of the Omnibus package. | String | `/opt/omnibus`
cache_dir       | The directory the Omnibus project uses for caching. | String | `/var/cache/omnibus`

Usage
=====

Include the `omnibus::default` recipe in your node's run list and override the
cookbook's default attributes as desired. At the very least you will want to
override `node['omnibus']['install_dir']` to match the installation directory
of your Omnibus project.

License and Author
==================

Author:: Seth Chisamore (<schisamo@opscode.com>)
Author:: Stephen Delano (<stephen@opscode.com>)

Copyright 2012-2013, Opscode, Inc. (<legal@opscode.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
