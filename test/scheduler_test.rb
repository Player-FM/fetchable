require_relative './test_helper'

class SchedulerTest < ActiveSupport::TestCase

  DECAYER = Fetchable::Schedulers::DecayingScheduler.new(
    success_wait: 1.hour,
    fail_wait: 10.minutes,
    fail_tries: 3,
    error_wait: 1.hour,
    error_wait_decay: 2
  )

  def test_simple_scheduler

    Timecop.freeze(now) do

      Document.settings.scheduler = Fetchable::Schedulers::SimpleScheduler.new(
        success_wait: 1.hour,
        fail_wait: 2.days
      )

      greeting.fetch
      assert_equal 1.hour.from_now, greeting.next_fetch_after
      greeting.url = Dummy::test_file(name: 'does-not-exist')
      greeting.fetch
      assert_equal 2.days.from_now, greeting.next_fetch_after
    end

  end

  def test_decaying_scheduler_sucess

    Document.settings.scheduler = DECAYER

    Timecop.freeze(now) do
      greeting.fetch
      assert_equal now+1.hour, greeting.next_fetch_after
    end

  end

  def test_decaying_scheduler_fails

    start = now
    future = nil
    Document.settings.scheduler = DECAYER
    greeting.url = Dummy::test_file(name: 'does-not-exist')

    Timecop.freeze(start) do
      greeting.fetch
      assert_equal future=start+10.minutes, greeting.next_fetch_after
    end

    Timecop.freeze(future) do
      greeting.fetch
      assert_equal future=start+20.minutes, greeting.next_fetch_after
    end

    Timecop.freeze(future) do
      greeting.fetch
      assert_equal future=start+30.minutes, greeting.next_fetch_after
    end

    Timecop.freeze(future) do
      greeting.fetch
      assert_equal future=start+(30+60).minutes, greeting.next_fetch_after
    end

    Timecop.freeze(future) do
      greeting.fetch
      assert_equal future=start+(30+60+120).minutes, greeting.next_fetch_after
    end

  end


end
