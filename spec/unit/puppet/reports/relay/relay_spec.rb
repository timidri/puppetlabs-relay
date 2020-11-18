require 'support/unit/reports/relay_spec_helper'

describe 'Relay report processor' do
  let(:processor) { new_processor }
  let(:settings_hash) { default_settings_hash }
  let(:expected_credentials) { default_credentials }
  let(:facts) { default_facts }

  before(:each) do
    mock_settings_file(settings_hash)
    allow(processor).to receive(:facts).and_return(facts)
  end

  # TODO: These tests need to be updated for the new HTTP clients.
  # it 'sends a node report' do
  #   allow(processor).to receive(:status).and_return 'changed'
  #   allow(processor).to receive(:host).and_return 'fqdn'
  #   mock_event_as_resource_status(processor, 'success', false)

  #   expect_sent_report(processor, expected_credentials) do |payload|
  #     expect(payload['data']['report']['status']).to eq('changed')
  #   end

  #   processor.process
  # end

  # context 'receiving response code greater than 200' do
  #   it 'returns the response code from Relay' do
  #     allow(processor).to receive(:status).and_return 'failed'
  #     mock_event_as_resource_status(processor, 'success', false)

  #     [300, 400, 500].each do |response_code|
  #       allow(processor).to receive(:do_request).and_return(new_mock_response(response_code, ''))
  #       expect { processor.process }.to raise_error(RuntimeError, %r{(status: #{response_code})})
  #     end
  #   end
  # end
end
