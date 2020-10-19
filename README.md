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

You must already have a puppetserver to which puppet agents submit reports and
that can connect to the internet.

You must also have a Relay account registered. You can sign up for one at
[https://relay.sh/](https://relay.sh/) if you do not already have one.

### Configuration

The report processor also needs a Relay push-trigger access token that is
authorized to talk to the Relay API. To get an access token, add a workflow
push trigger to a Relay workflow and copy the token from the sidebar.

Please see [our
documentation](https://relay.sh/docs/reference/relay-workflows/#push) for
further details on configuring push triggers.

### Deployment

The report processor may be automatically set up by classifying the
puppetserver host with the `relay::reporting` class. This class will:

1. configure the report processor list of the puppetserver to include the
   `relay` report processor
1. place the access token in the appropriate location for the report processor
1. reload the puppetserver process to load the new report processor

The classification will look something like this:

```puppet
class { 'relay::reporting':
  access_token => 'eyJhbGciOiJ......XUsf3o',
}
```

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

This is class used to configure the report processor.

#### Parameters

##### `access_token`

*Required:* The token by which the report processor authenticates to the Relay
API. Valid options: 'string'.

##### `reports_url`

The URL of the Relay events API. Valid option: 'string'

Default: 'https://api.relay.sh/api/events'

### Relay trigger properties

Every relay trigger payload has properties that can be acted upon. The
properties for this trigger are derived from the puppet report object as
detailed in [the official
documentation](https://puppet.com/docs/puppet/6.17/format_report.html).

##### `report.host`

Type: string

The hostname that submitted the report.

##### `report.logs`

Type: array of strings

An array of the log lines that were `notice` severity or greater. This is
useful for matching based on changes performed by specific classes, resource
types, resource titles, property values, etc.

##### `report.summary`

Type: string

This is the long-form summary of the puppet run. It is more useful from a human
perspective but may be inspected programmatically for puppet run information.

##### `report.status`

Type: string

This is the run status. Useful for detecting runs that caused changes, or runs
that were failures.

##### `report.time`

Type: string

The timestamp of when the puppet run began.

##### `facts`

Type: hash

This is the full hash of puppet facts on the host at report time.

## Limitations

The report processor submits a subset of the full report. Full report
submission will come soon, as they need to be compressed before transmission.
