module PuppetX
  module Relay
    class Runner
      def self.get(runner)
        require_relative "runner/#{arg.intern}"
        Object.const_get('PuppetX::Relay::Runner').const_get(runner)
      end
    end
  end
end
