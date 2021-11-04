require 'net/http'
require 'openssl'

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
            http.verify_callback = -> (verify_ok, store_context) {
              cert = store_context.current_cert
              chain = store_context.chain
              failed_cert_reason = [store_context.error, store_context.error_string] if store_context.error != 0
              verify_ok
            }

            update_http!(http)

            puts("in request 0")
            puts(http.ca_path)
            store = OpenSSL::X509::Store.new
            store.set_default_paths
            store.add_file(Puppet[:cacert])
            newstore = store.add_file(Puppet[:cacrl])
            http.cert_store = newstore
            puts(store)
            puts(newstore)
            puts(http.cert_store.to_s)
            puts("in request 1")
            puts(http.cert_store.chain)
            puts("in request 2")

            http.start { |sess| sess.request(req) }
          rescue OpenSSL::SSL::SSLError => e
            error = e.message
            error = "error code %d: %s" % failed_cert_reason if failed_cert_reason
            if error =~ /certificate verify failed/
              domains = cert_domains(cert)
              if matching_domains(domains, uri.host).none?
                error = "hostname \"#{uri.host}\" does not match the server certificate (#{domains.join(', ')})"
              end
            end
            @logger&.info { "SSLTest #{url} finished: #{error}" }
            return [false, error, cert]
          rescue => e
            @logger&.error { "SSLTest #{url} failed: #{e.message}" }
            return [nil, "SSL certificate test failed: #{e.message}", cert]
          end

          def get(path)
            request(:get, path)
          end

          def post(path, body: nil)
            request(:post, path, body: body)
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
