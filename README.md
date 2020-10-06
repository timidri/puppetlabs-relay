# relay

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with relay](#setup)
    * [What relay affects](#what-relay-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with relay](#beginning-with-relay)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module configures a report processor to submit any changed resources to
the Relay SaaS event trigger API. Workflows may subscribe to the triggers and
decide whether to run based on the run status and log lines.

## Setup

The relay processor must be pluginsync'd before it can be used. The report
processor may be manuLly configured, or may be configured by using the
`relay::reporting` class

### Setup Requirements

The report processor requires a puppet compile host to which agents submit
reports. The report processor also needs an access token that is authorized to
talk to the Relay API.

## Usage

* Create a push trigger in a workflow
* classify any puppet primary servers and compile servers with the class
* and workflow steps to act on status and logs

Include usage examples for common use cases in the **Usage** section. Show your
users how to use your module to solve problems, and be sure to include code
examples. Include three to five examples of the most important or common tasks a
user can accomplish with your module. Show users how to accomplish more complex
tasks that involve different types, classes, and functions working in tandem.

## Reference

### `relay::reporting`

#### Parameters

##### `access_token`

The token by which the report processor authenticates to the Relay API. Valid
options: 'string'.

##### `reports_url`

The URL of the Relay events API. Valid option: 'string'

Default: 'https://api.relay.sh/api/events'

## Limitations

The report processor submits a subset of the full report. Full report
submission will come soon, as they need to be compressed before transmission.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
