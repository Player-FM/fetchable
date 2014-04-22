require_relative './test_helper'

class SchedulerTest < ActiveSupport::TestCase

  def test_successful_call

    Timecop.freeze(now) do
      greeting.fetch
      assert_equal 1.hour.from_now, greeting.next_fetch_after
      greeting.url = Dummy::test_file(name: 'does-not-exist')
      greeting.fetch
      assert_equal 2.days.from_now, greeting.next_fetch_after
    end

  end


end
