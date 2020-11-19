require_relative 'base'

module PuppetX
  module Relay
    module Agent
      module Backend
        class Dummy < Base
          def exec(run, schedule)
            new_state =
              if schedule.elapsed > 5
                run.state.to_complete(outcome: 'finished')
              else
                run.state.to_in_progress(schedule.next_update_before)
              end

            run.with_state(new_state)
          end
        end
      end
    end
  end
end
