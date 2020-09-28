require 'json'
require 'spec_helper'
require 'support/unit/reports/shared_examples'

require 'puppet/reports'

def new_processor
  processor = Puppet::Transaction::Report.new('apply')
  processor.extend(Puppet::Reports.report(:relay))

  allow(processor).to receive(:time).and_return '00:00:00'
  allow(processor).to receive(:host).and_return 'host'
  allow(processor).to receive(:job_id).and_return '1'
  allow(processor).to receive(:time).and_return(Time.now)
  allow(processor).to receive(:metrics).and_return('time' => { 'total' => 0 })
  # The report processor logs all exceptions to Puppet.err. Thus, we mock it out
  # so that we can see them (and avoid false-positives).
  allow(Puppet).to receive(:err) do |msg|
    raise msg
  end

  processor
end

def default_settings_hash
  {
    'reports_url'  => 'https://api.test/api/events',
    'access_token' => 'test_token',
  }
end

def default_credentials
  {
    :access_token => 'test_token',
  }
end

def mock_settings_file(settings_hash)
  allow(YAML).to receive(:load_file).with(%r{relay_reporting\.yaml}).and_return(settings_hash)
end

def new_mock_response(status, body)
  response = instance_double('mock HTTP response')
  allow(response).to receive(:code).and_return(status.to_s)
  allow(response).to receive(:body).and_return(body)
  response
end

def new_mock_event(event_fields = {})
  event_fields[:property] = 'message'
  event_fields[:message]  = 'defined \'message\' as \'hello\''
  Puppet::Transaction::Event.new(event_fields)
end

def new_mock_resource_status(events, status_changed, status_failed)
  status = instance_double('resource status')
  allow(status).to receive(:events).and_return(events)
  allow(status).to receive(:out_of_sync).and_return(status_changed)
  allow(status).to receive(:failed).and_return(status_failed)
  allow(status).to receive(:containment_path).and_return(['foo', 'bar'])
  allow(status).to receive(:file).and_return('site.pp')
  allow(status).to receive(:line).and_return(1)
  status
end

def mock_events(processor, *events)
  allow(processor).to receive(:resource_statuses).and_return('mock_resource' => new_mock_resource_status(events, true, false))
end

def mock_event_as_resource_status(processor, event_status, event_corrective_change, status_changed = true, status_failed = false)
  mock_events = [new_mock_event(status: event_status, corrective_change: event_corrective_change)]
  mock_resource_status = new_mock_resource_status(mock_events, status_changed, status_failed)
  allow(processor).to receive(:resource_statuses).and_return('mock_resource' => mock_resource_status)
end

def expect_sent_report(expected_credentials = {})
  # do_request will only be called to send an event
  expect(processor).to receive(:do_request) do |endpoint, _, request_body, actual_credentials|
    yield request_body
    expect(actual_credentials).to include(expected_credentials)
    new_mock_response(200, '')
  end
end

def short_description_regex(status)
  # Since the formatted time string is regex only precise to the minute, the unit tests
  # execute fast enough that race conditions and intermittent failures shouldn't
  # be a problem.
  Regexp.new(%r{Puppet.*#{Regexp.escape(status)}.*#{processor.host} \(report time: #{Time.now.strftime('%F %H:%M')}.*\)})
end

def default_facts
  {
    'id' => 'foo',
    'ipaddress' => '192.168.0.1',
    'memorysize' => '7.80 GiB',
    'memoryfree' => '2.05 GiB',
    'os' => {
      'architecture' => 'amd64',
      'distro' => {
        'codename' => 'xenial',
        'description' => 'Ubuntu 16.04.5 LTS',
        'id' => 'Ubuntu',
        'release' => {
          'full' => '16.04',
          'major' => '16.04',
        },
      },
      'family' => 'Debian',
      'hardware' => 'x86_64',
      'name' => 'Ubuntu',
      'release' => {
        'full' => '16.04',
        'major' => '16.04',
      },
      'selinux' => { 'enabled' => false },
    },
  }
end
