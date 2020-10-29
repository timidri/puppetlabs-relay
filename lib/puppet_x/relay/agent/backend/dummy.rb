require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Backend
        class Dummy < Base
          def exec(run)
            # Let some time pass.
            sleep(5)

            # Update state to complete.
            run = run.with_state(run.state.to_complete(outcome: 'finished'))

            _resp = @relay_api.put_run_state(run)
            # XXX: FIXME: Handle errors here!

            run
          end
        end
      end
    end
  end
end
