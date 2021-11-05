require 'net/http'
require 'openssl'
require 'ssl-test'
require 'puppet'

module PuppetX
  module Relay
    module Util
      module HTTP
        class Client
          def initialize(base_url)
            @base_url = base_url
          end

          # @param verb [Symbol]
          # @param path [String]
          # @return [Net::HTTPResponse]
          def request(verb, path, body: nil)
            uri = URI.join(@base_url, path)

            req = Object.const_get("Net::HTTP::#{verb.to_s.capitalize}").new(uri)
            req['Content-Type'] = 'application/json'
            req.body = body.to_json if body

            update_request!(req)

            http = Net::HTTP.new(uri.host, uri.port)
            http.set_debug_output($stdout)
            http.use_ssl = uri.scheme == 'https'
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER

            update_http!(http)

            valid, error, cert = SSLTest.test "https://api.relay.sh"
            puts("valid: ", valid)
            puts("error: ", error)
            puts("cert: ", cert)
            http.start { |sess| sess.request(req) }
          end

          def request2(verb, path, body=nil)
            url = URI.join(@base_url, path)

            headers = { "Content-Type" => "application/json" }
            update_request!(headers)

            # This metric_id option is silently ignored by Puppet's http client
            # (Puppet::Network::HTTP) but is used by Puppet Server's http client
            # (Puppet::Server::HttpClient) to track metrics on the request made to the
            # `reporturl` to store a report.
            options = {
              :metric_id => [:puppet, :report, :relay],
              :include_system_store => true,
            }

            client = Puppet.runtime[:http]
            body = body.to_json if body
            client.post(url, body, headers: headers, options: options) do |response|
              unless response.success?
                Puppet.err _("Unable to submit report to %{url} [%{code}] %{message}") % { url: url.to_s, code: response.code, message: response.reason }
              end
            end
          end

          def get(path)
            request(:get, path)
          end

          def post(path, body: nil)
            request2(:post, path, body: body)
          end

          def put(path, body: nil)
            request(:put, path, body: body)
          end

          protected

          # @param http [Net::HTTP]
          def update_http!(http); end

          # @param request [Net::HTTPGenericRequest]
          def update_request!(request); end
        end
      end
    end
  end
end
