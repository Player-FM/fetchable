require_relative './test_helper'

class EventTest < ActiveSupport::TestCase

  def test_callback_sequence
    greeting.expects(:handle_fetch_started)
    greeting.expects(:handle_fetch_ended)
    greeting.expects(:handle_failed).never
    greeting.fetch
  end

  def test_body_access
    greeting.fetch
    assert_equal 'ohai', greeting.body
  end

  def test_fetch_change_fires_iff_content_changes
    greeting.fetch

    greeting.expects(:handle_fetch_changed).never
    greeting.fetch

    greeting.url = Dummy::test_file(name: 'farewell.txt', last_modified: '_')
    greeting.expects(:handle_fetch_changed)
    greeting.expects(:handle_fetch_changed_and_ended)
    greeting.fetch
  end

  def test_change_handler_can_veto_change

    start = now
    Timecop.freeze(start) do
      greeting.fetch
      assert_equal start, greeting.fetch_changed_at
    end
    
    Timecop.freeze(start+5.minutes) do
      greeting.url = Dummy::test_file(name: 'farewell.txt', etag: '_', last_modified: '_')
      greeting.stubs(:handle_fetch_changed).returns(false)
      greeting.fetch
      assert_equal start, greeting.fetch_changed_at
    end

  end

  def test_refetch_event_after_304
    greeting.fetch
    greeting.expects(:handle_fetch_started)
    greeting.expects(:handle_fetch_ended)
    greeting.expects(:handle_fetch_changed).never
    greeting.expects(:handle_fetch_changed_and_ended).never
    greeting.fetch
  end

  def test_error_event_after_404
    greeting.expects(:handle_fetch_started)
    greeting.expects(:handle_fetch_failed)
    greeting.expects(:handle_fetch_ended)
    greeting.url = Dummy::test_file(name: 'does-not-exist')
    greeting.fetch
  end

  def test_refetch_event_after_302
    greeting.expects(:handle_fetch_started)
    greeting.expects(:handle_fetch_redirected)
    greeting.expects(:handle_fetch_ended)
    greeting.url = Dummy::test_file(name: 'greeting.txt', redirect: '2')
    greeting.fetch
  end


end
