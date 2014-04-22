require_relative './test_helper'

class EventTest < ActiveSupport::TestCase

  def test_callback_sequence
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_after_fetch)
    greeting.expects(:handle_refetch).never
    greeting.fetch
  end

  def test_body_access
    greeting.fetch
    assert_equal 'ohai', greeting.body
  end

  def test_updated_fetch_event

    greeting.fetch

    greeting.expects(:handle_fetch_update).never
    greeting.fetch

    greeting.url = Dummy::test_file(name: 'farewell.txt', last_modified: '_')
    greeting.expects(:handle_fetch_update)
    greeting.fetch

  end

  def test_refetch_event_after_304
    greeting.fetch
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_after_fetch)
    greeting.expects(:handle_refetch)
    greeting.fetch
  end

  def test_error_event_after_404
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_fetch_error)
    greeting.expects(:handle_after_fetch)
    greeting.url = Dummy::test_file(name: 'does-not-exist')
    greeting.fetch
  end

  def test_refetch_event_after_302
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_fetch_redirect)
    greeting.expects(:handle_after_fetch)
    greeting.url = Dummy::test_file(name: 'greeting.txt', redirect: '2')
    greeting.fetch
  end

end
