require_relative './test_helper'

class RefetchTest < ActiveSupport::TestCase

  def setup
    greeting.fetch
    assert_not_nil greeting.etag
  end

  def test_no_mementos_means_full_refetch
    Timecop.freeze(now) do
      greeting.url = Dummy::test_file(name: 'greeting.txt', etag: '_', last_modified: '_')
      greeting.fetch
      assert_equal 200, greeting.status_code
      assert_equal now, greeting.fetch_tried_at
      assert_equal 0, greeting.fetch_fail_count
    end
  end

  def test_etag_means_minimal_refetch
    Timecop.freeze(now) do
      greeting.url = Dummy::test_file(name: 'greeting.txt', last_modified: '_')
      greeting.fetch
      assert_equal 304, greeting.status_code
      assert_equal now, greeting.fetch_succeeded_at
      assert_equal now, greeting.fetch_tried_at
      assert_equal 0, greeting.fetch_fail_count
    end
  end

  def test_modified_since_means_minimal_refetch
    greeting.url = Dummy::test_file(name: 'greeting.txt', etag: '_')
    greeting.fetch
    assert_equal 304, greeting.status_code
  end

end
