require 'optparse'

module Fetchable
  module Runners
    class LoopRunner < Hashie::Dash

      property :duration
      property :all, default: false

      def run(fetchable_scope)
        success = 0
        total = 0
        fetchable_scope.ready_for_fetch.find_each { |fetchable|
          fetchable.fetch
          success +=1 if fetchable.ok?
          total+=1
        }
        puts "Success: #{success}. Total: #{total}"
      end

    end
  end
end
