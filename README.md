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

### Requirements

You must already have a puppetserver to which puppet agents submit reports.

You must already have a Relay account registered. You can sign up for one at
[https://relay.sh/](https://relay.sh/) if you do not already have one.

### Configuration

The report processor also needs a Relay push-trigger access token that is
authorized to talk to the Relay API.

### Deployment

The report processor may be automatically set up by classifying the
puppetserver host with the `relay::reporting` class. This class will:

1. configure the report processor list of the puppetserver to include the relay
   report processor
1. place the access token in the appropriate location for the report
processor
1. reload the puppetserver process

The classification will look something like this:

```puppet
class profile::relay_reporting {
  class { 'relay::reporting':
    access_token => 'eyJhbGciOiJ......XUsf3o',
  }
}
```

To get an access token prior to deploying the report processor, a workflow push
token must be configured in Relay.

Please see [our
documentation](https://relay.sh/docs/reference/relay-workflows/#push) on
creating push triggers for details on configuring this.

<!--
## Usage


TODO This area needs filling out.

This should describe how to have steps that actually act on the changed
resources and the state of a report, but I think that will have to come later

* Create a push trigger in a workflow
* classify any puppet primary servers and compile servers with the class
* and workflow steps to act on status and logs

-->

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
