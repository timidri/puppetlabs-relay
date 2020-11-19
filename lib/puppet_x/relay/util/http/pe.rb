require 'openssl'

require 'puppet'
require 'puppet/util/package'

require_relative 'client'

module PuppetX
  module Relay
    module Util
      module HTTP
        class PE < Client
          def initialize(base_url, token)
            super(base_url)
            @token = token
          end

          protected

          def update_http!(http)
            http.cert_store = store

            http.ssl_version =
              if Puppet::Util::Package.versioncmp(Puppet.version, '6.0')
                :TLSv1_2
              else
                :TLSv1
              end

            http.key = OpenSSL::PKey::RSA.new(File.read(Puppet.settings[:hostprivkey]))
            http.cert = OpenSSL::X509::Certificate.new(File.read(Puppet.settings[:hostcert]))
          end

          def update_request!(request)
            request['X-Authentication'] = @token if @token
          end

          private

          def store
            store = OpenSSL::X509::Store.new
            store.set_default_paths
            store.add_file(Puppet[:cacert])
            store.add_file(Puppet[:cacrl])
          end
        end
      end
    end
  end
end
