require_relative './test_helper'

class EventTest < ActiveSupport::TestCase

  def test_callback_sequence
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_after_fetch)
    greeting.expects(:handle_refetch).never
    greeting.fetch
  end

  def test_refetch_after_304
    greeting.fetch
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_after_fetch)
    greeting.expects(:handle_refetch)
    greeting.fetch
  end

  def test_error_after_404
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_fetch_error)
    greeting.expects(:handle_after_fetch)
    greeting.url = Dummy::test_file(name: 'does-not-exist')
    greeting.fetch
  end

  def test_error_after_404
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_fetch_redirect)
    greeting.expects(:handle_after_fetch)
    greeting.url = Dummy::test_file(name: 'greeting.txt', redirect: '2')
    greeting.fetch
  end

end
