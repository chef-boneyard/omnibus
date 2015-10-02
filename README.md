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
The default recipe is the main entrypoint for the cookbook and does the following:

- Ensures all required Omnibus-related directories are created and owned by the build user.
- Ensures a sane build tool-chain is installed and configured (using the [build-essential](http://community.opscode.com/cookbooks/build-essential) cookbook)
- Ensures git is installed (using the [git](http://community.opscode.com/cookbooks/git) cookbook)
- Includes a platform-specific recipe to apply additional tweaks as appropriate.

All other recipes should be treated as "private" and are not meant to be used individually. They only exist to support the `default` recipe.


Attributes
----------
| Attribute     | Default              | Description                           |
|---------------|----------------------|---------------------------------------|
| `build_user`  | `omnibus`            | The user to perform the Omnibus build |
| `install_dir` | `/opt/omnibus`       | The directory to install Omnibus      |
| `cache_dir`   | `/var/cache/omnibus` | The cache directory for Omnibus       |


Resources
---------

### omnibus_build

This resource is used to execute a build of an Omnibus project.

#### Attributes

| Attribute          | Default                                               | Description                           |
|--------------------|-------------------------------------------------------|---------------------------------------|
| `project_name`     |                                                       | The name of the Omnibus project to build |
| `project_dir`      |                                                       | The directory to install Omnibus |
| `install_dir`      | `/opt/<PROJECT>`                                      | The installation of the project being built |
| `omnibus_base_dir` | Windows: 'C:/omnibus-ruby' *nix: '/var/cache/omnibus' | The cache directory for Omnibus |
| `log_level`        | `:internal`                                           | Log level used during the build. Valid values include: `:internal, :debug, :info, :warn, :error, :fatal` |
| `config_file`      | `<PROJECT_DIR>/omnibus.rb`                            | Omnibus configuration file used for the build. |
| `config_overrides` | `{}`                                                  | Overrides for one or more Omnibus config options |
| `expire_cache`     | `false`                                               | Indiciates the Omnibus cache (including git cache) should be wiped before building.  |
| `build_user`       | `node['omnibus']['build_user']`                       | The user to execute the Omnibus build as. |
| `environment`      | `{}`                                                  | Environment variables to set in the underlying build process. |

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


Testing
-------
You can run the tests in this cookbook using Rake:

```text
rake integration  # Run Test Kitchen integration tests
rake style        # Run all style checks
rake style:chef   # Lint Chef cookbooks
rake style:ruby   # Run Ruby style checks
rake travis:ci    # Run tests on Travis
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
