# Fluentd

[![Build Status](https://travis-ci.org/soylent/konstantin-fluentd.svg?branch=master)](https://travis-ci.org/soylent/konstantin-fluentd)

Install, configure, and manage Fluentd data collector.

## Module Description

* Installs `td-agent` package
* Generates configuration file `td-agent.conf`
* Generates custom configuration files and saves them to `config.d/`
* Manages `td-agent` service
* Installs Fluentd gem plugins

## Usage Examples

### Basic

Install and start the service.

```puppet
class { 'fluentd': }
```

### Routing Events To Elasticsearch

Receive logs from other Fluentd instances and via UNIX domain socket. Forward
the logs to Elasticsearch.

```puppet
include fluentd

fluentd::plugin { 'fluent-plugin-elasticsearch': }

fluentd::config { '500_elasticsearch.conf':
  config => {
    'source' => [
      {
        'type' => 'forward',
      },
      {
        'type' => 'unix',
        'path' => '/tmp/td-agent/td-agent.sock',
      },
    ],
    'match'  => {
      'tag_pattern'     => '**',
      'type'            => 'elasticsearch',
      'index_name'      => 'foo',
      'type_name'       => 'bar',
      'logstash_format' => true,
    }
  }
}
```

### Forwarding Events To Fluentd Aggregator

Read logs from UNIX domain socket, then forward them to Fluentd aggregators.

```puppet
include fluentd

fluentd::config { '600_forwarding.conf':
  config => {
    'source' => {
      'type' => unix,
      'path' => '/tmp/td-agent/td-agent.sock',
    },
    'match'  => {
      'tag_pattern' => '**',
      'type'        => forward,
      'server'      => [
        { 'host' => 'example1.com', 'port' => 24224 },
        { 'host' => 'example2.com', 'port' => 24224 },
      ]
    }
  }
}
```

### Hiera Support

Defining Fluentd resources in Hiera.

```yaml
fluentd::plugins:
  'fluent-plugin-http':
    plugin_ensure: 0.1.0
  'fluent-plugin-elasticsearch':
    plugin_ensure: present
fluentd::configs:
  '100_fwd.conf':
    config:
      source:
        type: forward
  '200_stdout.conf':
    config:
      match:
        tag_pattern: test
        type: stdout
```

### Config File Naming

All configs employ a numbering system in the resource's title that is used for
ordering. When titling your config, make sure you prefix the filename with a
number, for example, `999_catch_all.conf`, `500_elasticsearch.conf` (999 has
smaller priority than 500)

## Reference

### Classes

#### Public Classes

* `fluentd`: Main class, includes all other classes.

#### Private Classes

* `fluentd::install`: Handles the packages.
* `fluentd::service`: Handles the service.

### Parameters

The following parameters are available in the `fluentd` class:

#### `repo_install`

Default value: true

#### `repo_name`

Default value: 'treasuredata'

#### `repo_desc`

Default value: 'TreasureData'

#### `repo_url`

Default value: 'http://packages.treasuredata.com/2/redhat/$releasever/$basearch'

#### `repo_enabled`

Default value: true

#### `repo_gpgcheck`

Default value: true

#### `repo_gpgkey`

Default value: 'https://packages.treasuredata.com/GPG-KEY-td-agent'

#### `repo_gpgkeyid`

Default value: 'C901622B5EC4AF820C38AB861093DB45A12E206F'

#### `package_name`

Default value: 'td-agent'

#### `package_ensure`

Default value: present

#### `service_name`

Default value: 'td-agent'

#### `service_ensure`

Default value: running

#### `service_enable`

Default value: true

#### `service_manage`

Default value: true

#### `service_provider`

Default value:

  - when `$facts['osfamily'] == 'redhat'`: redhat
  - otherwise: undef

#### `config_file`

Default value: '/etc/td-agent/td-agent.conf'

#### `config_path`

Default value: '/etc/td-agent/config.d'

#### `config_owner`

Default value: 'td-agent'

#### `config_group`

Default value: 'td-agent'

#### `configs`

Default value: {}

#### `plugins`

Default value: {}

### Public Defines

* `fluentd::config`: Generates custom configuration files.
* `fluentd::plugin`: Installs plugins.

The following parameters are available in the `fluentd::plugin` defined type:

#### `title`

Plugin name

#### `plugin_ensure`

Default value: present

#### `plugin_source`

Default value: 'https://rubygems.org'

#### `plugin_provider`

Default value: tdagent

#### `plugin_install_options`

Default value: []
see https://docs.puppetlabs.com/puppet/latest/reference/type.html#package-provider-gem,
e.g.

```puppet
plugin_install_options => [{'--http-proxy' => $http_proxy}]
```

The following parameters are available in the `fluentd::config` defined type:

#### `title`

Config filename

#### `config`

Config Hash, please see usage examples.

## Limitations

Tested on CentOS 6, CentOS 7, Ubuntu 14.04, Debian 7, 8, 9.

## Development

Bug reports and pull requests are welcome!

### Running Tests

    $ bundle install
    $ bin/rake lint
    $ bin/rake metadata_lint
    $ bin/rake spec
    $ bin/rspec spec/lib
    $ bin/rake beaker BEAKER_set=centos-6-x64
    $ bin/rake beaker BEAKER_set=centos-7-x64
    $ bin/rake beaker BEAKER_set=debian-7-amd64
    $ bin/rake beaker BEAKER_set=ubuntu-server-1404-x64

## License

Copyright SPB TV AG

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.

You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and limitations
under the License.
