require 'puppet'

require_relative '../../agent/model'
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
          end

          def update_request!(request)
            request['X-Authentication'] = @token
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
