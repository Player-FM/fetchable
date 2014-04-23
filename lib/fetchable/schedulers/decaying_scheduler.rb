module Fetchable
  module Schedulers
    class DecayingScheduler

      ATTRIBS = %w(success_wait fail_wait fail_tries error_wait error_wait_decay)

      attr_accessor :success_wait,
                    :fail_wait,
                    :fail_tries,
                    :error_wait,
                    :error_wait_decay

      def initialize(settings={})
        settings = Hashie::Mash.new(settings)
        ATTRIBS.each do |key|
          instance_variable_set "@#{key}", settings[key]
        end
      end

      def next_fetch_wait(fetchable)
        case fetchable.fail_count
        when 0
          @success_wait
        when 1..fail_tries
          @fail_wait
        else
          error_tries = fetchable.fail_count - fail_tries - 1 # subtract 1 so first error try is zeto'th
          (@error_wait*@error_wait_decay**error_tries).seconds
        end
      end

    end
  end
end
