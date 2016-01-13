omnibus Cookbook
================

[![Cookbook Version](https://img.shields.io/cookbook/v/omnibus.svg)](https://supermarket.chef.io/cookbooks/omnibus)

Prepares a machine to be an Omnibus builder.

This project is managed by the CHEF Release Engineering team. For more information on the Release Engineering team's contribution, triage, and release process, please consult the [CHEF Release Engineering OSS Management Guide](https://docs.google.com/a/opscode.com/document/d/1oJB0vZb_3bl7_ZU2YMDBkMFdL-EWplW1BJv_FXTUOzg/edit).

Requirements
------------
This cookbook requires Chef 11.0.0+.

For a full list of supported platforms and external cookbook requirements, please see the `metadata.rb` file at the root of the cookbook.


Recipes
-------
The default recipe is the main entry point for the cookbook and does the following:

- Ensures all required Omnibus-related directories are created and owned by the build user.
- Ensures a sane build toolchain is installed and configured (using the [build-essential](http://community.opscode.com/cookbooks/build-essential) cookbook or [Omnibus Toolchain](https://github.com/chef/omnibus-toolchain))
- Ensures git is installed (using the [git](http://community.opscode.com/cookbooks/git) cookbook)
- Includes a platform-specific recipe to apply additional tweaks as appropriate.

All other recipes should be treated as "private" and are not meant to be used individually. They only exist to support the `default` recipe.


Attributes
----------
| Attribute                  | Default                                               | Description |
|----------------------------|-------------------------------------------------------|-------------|
| `build_user`               | `omnibus`                                             | The user to execute Omnibus builds as |
| `base_dir`                 | Windows: `C:/omnibus-ruby` *nix: `/var/cache/omnibus` | The "base" directory where Omnibus will store its data |
| `build_user_home`          | `/home/<BUILD_USER>`                                  | Home directory of the build user |
| `install_dir`              | `/opt/<PROJECT>`                                      | The installation of the project being built |
| `toolchain_name`           | `omnibus-toolchain`                                   | Name of the full toolchain fat package to use |
| `toolchain_version`        | `1.1.2`                                               | Version of the full toolchain fat package to use |
| `toolchain_meta_bucket`    | `opscode-omnibus-package-metadata`                    | Amazon S3 bucket containing download urls of toolchain packages |
| `toolchain_package_bucket` | `opscode-omnibus-package-metadata`                    | Amazon S3 bucket containing toolchain packages ala [omnitruck](https://docs.chef.io/api_omnitruck.html)|
| `git_version`              | `2.6.2`                                               | Version of git to compile and install |
| `ruby_version`             | `2.1.5`                                               | Version of ruby to compile and install |


Resources
---------

### omnibus_build

This resource is used to execute a build of an Omnibus project.

#### Attributes

| Attribute          | Default                                               | Description |
|--------------------|-------------------------------------------------------|-------------|
| `project_name`     |                                                       | The name of the Omnibus project to build |
| `project_dir`      |                                                       | The directory to install Omnibus |
| `install_dir`      | `/opt/<PROJECT>`                                      | The installation of the project being built |
| `base_dir`         | Windows: `C:/omnibus-ruby` *nix: `/var/cache/omnibus` | The base directory for Omnibus |
| `log_level`        | `:internal`                                           | Log level used during the build. Valid values include: `:internal, :debug, :info, :warn, :error, :fatal` |
| `config_file`      | `<PROJECT_DIR>/omnibus.rb`                            | Omnibus configuration file used for the build |
| `config_overrides` | `{}`                                                  | Overrides for one or more Omnibus config options |
| `expire_cache`     | `false`                                               | Indiciates the Omnibus cache (including git cache) should be wiped before building.  |
| `build_user`       | `node['omnibus']['build_user']`                       | The user to execute the Omnibus build as |
| `environment`      | `{}`                                                  | Environment variables to set in the underlying build process |

#### Example Usage

```ruby
omnibus_build 'harmony' do
  project\_dir 'https://github.com/chef/omnibus-harmony.git'
  log_level :internal
  config_override(
    append_timestamp: true
  )
end
```

Usage
-----
Include the `omnibus::default` recipe in your node's run list and override the cookbook's default attributes as desired. At the very least you will want to override `node['omnibus']['install_dir']` to match the installation directory of your Omnibus project.

Using Test Kitchen with Docker
------------------------------

The following assumes you are on a Mac OS X workstation and have installed and
started [Kitematic](https://kitematic.com/).

* Install [kitchen-docker](https://github.com/portertech/kitchen-docker) into your local ChefDK install:
```
$ chef gem install kitchen-docker
Successfully installed kitchen-docker-2.3.0
1 gem installed
```

* Set environment variables to point kitchen-docker at your local Kitematic instance:
```
# Bash
export DOCKER_HOST=tcp://192.168.99.100:2376
export DOCKER_CERT_PATH=$HOME/.docker/machine/certs
export DOCKER_TLS_VERIFY=1

# Fish
set -gx DOCKER_HOST "tcp://192.168.99.100:2376"
set -gx DOCKER_CERT_PATH "$HOME/.docker/machine/certs"
set -gx DOCKER_TLS_VERIFY 1
```

* Run Test Kitchen with the provided `.kitchen.docker.yml`:
```
KITCHEN_LOCAL_YAML=.kitchen.docker.yml kitchen verify languages-ruby-ubuntu-1204
```

License & Authors
-----------------
- Author: Seth Vargo (<sethvargo@gmail.com>)
- Author: Yvonne Lam (<yvonne@chef.io>)
- Author: Seth Chisamore (<schisamo@chef.io>)
- Author: Stephen Delano (<stephen@chef.io>)

```text
Copyright 2012-2015, Chef Software, Inc. (<legal@chef.io>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
