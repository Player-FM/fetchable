require_relative './test_helper'

class InterruptionTest < ActiveSupport::TestCase

  def test_attribs_after_error_response
    assert_nil greeting.fetch_succeeded_at
    start = now + 10.minutes
    Timecop.freeze(start) do
      greeting.url = Dummy::test_file(name: 'does-not-exist')
      greeting.fetch
      assert_equal 404, greeting.status_code
      assert_equal 1, greeting.fetch_fail_count
      assert_equal start, greeting.fetch_tried_at
      assert_nil greeting.fetch_succeeded_at
      greeting.fetch
      assert_equal 2, greeting.fetch_fail_count
    end
  end

  def test_error_doesnt_wipe_out_attribs_from_last_successful_call

    original = nil
    Timecop.freeze(start = now) do
      greeting.fetch
      original = greeting.clone
    end

    Timecop.freeze(later = now+5.hours) do
      greeting.url = Dummy::test_file(name: 'does-not-exist')
      greeting.fetch
      assert_equal start, greeting.fetch_succeeded_at
      assert_equal later, greeting.fetch_tried_at
      assert_equal original.fingerprint, greeting.fingerprint
      assert_equal original.etag, greeting.etag
    end

  end

=begin
  # no longer swallowed
  def test_exception_is_handled
    greeting.url = nil
    greeting.fetch
  end
=end

  def test_incomplete_fetch_doesnt_trigger_change
  end

end
