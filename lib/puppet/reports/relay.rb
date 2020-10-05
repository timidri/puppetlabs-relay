require 'puppet/util/relay'
require 'zlib'
require 'base64'

Puppet::Reports.register_report(:relay) do
  desc "Submit report to Relay workflow trigger"

  include Puppet::Util::Relay

  def process
    settings_hash = settings

    if settings_hash['reports_url'] == nil
      settings_hash['reports_url'] = 'https://api.relay.sh/api/events'
    end
    if settings_hash['access_token'] != nil
      process_report(settings_hash)
    else
      Puppet.warn "relay report processor warning: no access_token found; not submitting report"
    end

  rescue StandardError => e
    Puppet.err "relay report processor error: #{e}\n#{e.backtrace}"
  end

  def process_report(settings_hash)
    endpoint = settings_hash['reports_url']

    # Noop is unchanged status, but need to submit these
    # unless status == 'unchanged'
    Puppet.info(relay_log_entry("attempting to send the report to #{endpoint}"))

    response = do_request(
      endpoint,
      'Post',
      {
        'data' => { 'report' => {
          'host'    => host,
          'logs'    => logs.each_with_object([]) do |log, a|
            a.push("#{log.source}: #{log.message}") unless [:debug, :info].include? log.level
          end,
          'summary' => summary,
          'status'  => status,
          'time'    => time,
        } },
      },
      access_token: settings_hash['access_token'],
    )
    if response.code.to_i >= 300
      raise "Failed to send the report. Error from #{endpoint} (status: #{response.code}): #{response.body}"
    end

    Puppet.info(relay_log_entry('successfully sent the report'))

    true
  end
end
