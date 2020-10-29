require 'puppet'
require 'puppet/util'

# hiera-eyaml requires. Note that newer versions of puppet-agent
# ship with the hiera-eyaml gem so these should work.
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'hiera/backend/eyaml/subcommand'

module PuppetX
  module Relay
    module Util
      module Relay
        def relay_log_entry(msg)
          "relay report processor: #{msg}"
        end

        module_function :relay_log_entry

        def settings(settings_file = Puppet[:confdir] + '/relay_reporting.yaml')
          settings_hash = YAML.load_file(settings_file)

          # Since we also support hiera-eyaml encrypted tokens, we'll want to decrypt
          # the token before passing it into the request. In order to do that, we
          # first check if hiera-eyaml's configured on the node. If yes, then we run
          # the token through hiera-eyaml's parser. The parser will decrypt the token
          # if it is encrypted; otherwise, it will leave it as-is so that plain-text
          # token are unaffected.
          hiera_eyaml_config = nil
          begin
            # Note: If hiera-eyaml config doesn't exist, then load_config_file returns
            # the hash {:options => {}, :sources => []}
            hiera_eyaml_config = Hiera::Backend::Eyaml::Subcommand.load_config_file
          rescue StandardError => e
            raise "error reading the hiera-eyaml config: #{e}"
          end
          unless hiera_eyaml_config[:sources].empty?
            # hiera_eyaml config exists so run the token through the parser. Note that
            # we chomp the token to support syntax like:
            #
            #   access_token: >
            #       ENC[Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
            #       NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
            #       ...
            #
            # where the '>' will add a trailing newline to the encrypted token.
            Hiera::Backend::Eyaml::Options.set(hiera_eyaml_config[:options])
            parser = Hiera::Backend::Eyaml::Parser::ParserFactory.hiera_backend_parser

            if (access_token = settings_hash['access_token'])
              access_token_tokens = parser.parse(access_token.chomp)
              access_token = access_token_tokens.map(&:to_plain_text).join
              settings_hash['access_token'] = access_token
            end
          end

          settings_hash
        end
        module_function :settings
      end
    end
  end
end
