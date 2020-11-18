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

Second, it runs a Relay agent on your puppetserver which can be used to trigger
puppet run (without requiring inbound connectivity to your puppetserver).

## Setup

### 0. Requirements

You must already have a puppetserver to which puppet agents submit reports and
that can connect to the internet.

You must also have a Relay account registered. You can sign up for one at
[https://relay.sh/](https://relay.sh/) if you do not already have one.

### 1. Setup the Relay workflow

The report processor needs a Relay push-trigger access token that is
authorized to talk to the Relay API. To get an access token, add a workflow
push trigger to a Relay workflow and copy the token from the sidebar.

The workflow trigger in Relay will look something like this:
```yaml
triggers:
  - name: puppet-report
    source:
      type: push
    binding:
      parameters:
        host: !Data host
        resource_statuses: !Data resource_statuses
        status: !Data status
        time: !Data time
        facts: !Data facts
```

You'll then copy the access token from the sidebar:
![ Copying access token from the sidebar](https://github.com/puppetlabs/puppetlabs-relay/raw/tasks/update-instructions/media/push-trigger.png)

To see an example of a Relay workflow that uses this trigger, [check it
out here](https://github.com/puppetlabs/relay-workflows/tree/master/puppet-shutdown-ec2).

Please see [our
documentation](https://relay.sh/docs/reference/relay-workflows/#push) for
further details on configuring push triggers.

### 2. Configure the puppetserver

The report processor may be automatically set up by classifying the puppetserver
host with the `relay` class. This class will:

1. configure the report processor list of the puppetserver to include the
   `relay` report processor if you specify one or more trigger tokens
1. (on Puppet Enterprise) reload the puppetserver process to load the new report
   processor
1. configure the agent to synchronize with the Relay service if you specify a
   connection token
1. set up the Relay agent configuration and service to run automatically

The classification will look something like this for Puppet Enterprise:

```puppet
class { 'relay':
  relay_trigger_token => [
    Sensitive('eyJhbG...OCMGbtUc'),
  ],
  relay_connection_token => Sensitive('eyJhbG...adQssw5c'),
  backend_options => {
    # This is a Puppet RBAC token for connecting to the Orchestrator API,
    # generated using the `puppet-access` command.
    token => Sensitive('0a1Tje...ng-3eq4'),
  },
}
```

For open source Puppet, the agent can use Bolt to execute the Puppet agent:

```puppet
class { 'relay':
  # ...
  backend_options => {
    ssh_host_key_check => false,
    ssh_user => 'puppet-automation',
    ssh_password => Sensitive('@utom@tion'),
  },
}
```

## Example #1: Trigger Relay workflow from Puppet run

Run the Puppet agent (either in noop or enforce mode) to trigger the Relay workflow.

Note that the report will only be sent if resources are out of sync.

```bash
$ puppet agent -t --noop
```

## Example #2: Trigger Puppet run from Relay

Configure a Puppet step in your Relay workflow:
```yaml
- name: start-puppet-run
  image: relaysh/puppet-step-run-start
  spec:
    connection: !Connection { type: puppet, name: my-puppet-server }
    environment: production
    scope:
      nodes:
      - !Parameter host
```

When your Relay workflow runs, it will start a puppet run on the target host.

## Reference

### `relay` class

This is class used to configure the report processor and agent.

#### Parameters

##### `debug`

Type: Boolean

Whether to enable debug logging for the report processor and agent.

Default: `false`

##### `test`

Type: Boolean

Whether to enable test mode and verbosity for the report processor and agent.

Default: `false`

##### `relay_api_url`

Type: String

The base URL to the Relay API to connect to.

Default: `"https://api.relay.sh"`

##### `relay_connection_token`

Type: Sensitive[String]

The connection token to use for the agent. If not specified, the agent is
disabled.

##### `relay_trigger_token`

Type: Sensitive[String] or Array[Sensitive[String]]

One or more trigger tokens to use to start Relay workflows from the report
processor. If not defined or an empty array, the report processor is disabled.

##### `backend`

Type: String

The backend to use for running the Puppet agent.

Options:
- `"orchestrator"`
- `"bolt"`
- `"ssh"` (coming soon!)

Default: `"orchestrator"` in Puppet Enterprise, `"bolt"` otherwise.

##### `backend_options`

Type: Hash[String, Variant[Data, Sensitive[Data]]]

A hash of options to configure the given backend. The options available differ
depending on which backend is chosen.

For backend `"orchestrator"`:

* `api_url`: The URL to the orchestrator API. Make sure to include the trailing
  slash in the URL. Default: `"https://{puppetserver}:8143/orchestrator/v1/"`
* `token`: The RBAC token to use to access the orchestrator API. Sensitive.
  **Required.**

For backend `"bolt"`:

* `bolt_command`: The path to the Bolt command as an array. Default: `["bolt"]`
* `ssh_user`: The username to use to connect to the node to run Puppet on.
  Default: `"root"`
* `ssh_password`: The password to use to connect to the node to run Puppet on.
  Sensitive.
* `ssh_host_key_check`: Whether to enable host key checking for the target node.
  Default: `true`

##### `puppet_service`

Type: String

The name of the Puppet service.

Default: `"pe-puppetserver"` in Puppet Enterprise, `"puppetserver"` otherwise.

##### `puppet_user`

Type: String

The user the Puppet service and Relay agent run under.

Default: `"pe-puppet"` in Puppet Enterprise, `"puppet"` otherwise.

##### `puppet_group`

Type: String

The group the Puppet service and Relay agent run under.

Default: `"pe-puppet"` in Puppet Enterprise, `"puppet"` otherwise.

### Report processor event

Every relay trigger event payload includes several fields from the report. The
field are derived from the Puppet report object as detailed in [the official
documentation](https://puppet.com/docs/puppet/6.17/format_report.html).

#### Fields

##### `host`

The hostname that submitted the report.

##### `noop`

True if the agent was run in no-op mode, false if the agent was run in enforce
mode.

##### `facts`

This is the full hash of puppet facts on the host at report time as reported by
`facter`.

##### `status`

This is the run status (`"changed"`, etc.). Useful for detecting failures.

##### `time`

The timestamp of when the puppet run began in ISO 8601 format.

##### `configuration_version`

The version of the catalog applied to the node.

##### `transaction_uuid`

The unique identifier for the catalog run.

##### `code_id`

The code ID for the static file content server.

##### `summary`

This is the long-form summary of the puppet run. It is more useful from a human
perspective but may be inspected programmatically for puppet run information.

##### `resource_statuses`

For each resource that changed or was out of sync when the run occurred, a map of the resource name to an object containing:

* `resource_type`: The type of the resource, such as `File`
* `title`: The title of the resource, such as `/tmp/test`
* `change_count`: The number of property changes to the resource
* `out_of_sync_count`: The number of properties that were out of sync on the
  node

## Limitations

The report processor submits a subset of the full report. Full report submission
will come soon, as they need to be compressed before transmission.
