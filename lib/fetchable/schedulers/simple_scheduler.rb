module Fetchable
  module Schedulers
    class SimpleScheduler

      attr_accessor :success_wait, :fail_wait

      def initialize(settings={})
        settings = Hashie::Mash.new(settings)
        @success_wait = settings.success_wait||1.day
        @fail_wait = settings.fail_wait||1.day
      end

      def next_fetch_wait(fetchable)
        fetchable.ok? ? @success_wait : @fail_wait
      end

    end
  end
end
