require_relative './test_helper'

class RefetchTest < ActiveSupport::TestCase

  def setup
    greeting.fetch
    assert_not_nil greeting.resource.etag
  end

  def test_no_mementos_means_full_refetch
    greeting.url = Dummy::test_file(name: 'greeting.txt', etag: '_', last_modified: '_')
    greeting.fetch
    assert_equal 200, greeting.resource.status_code
  end

  def test_etag_means_minimal_refetch
    greeting.url = Dummy::test_file(name: 'greeting.txt', last_modified: '_')
    greeting.fetch
    assert_equal 304, greeting.resource.status_code
  end

  def test_modified_since_means_minimal_refetch
    greeting.url = Dummy::test_file(name: 'greeting.txt', etag: '_')
    greeting.fetch
    assert_equal 304, greeting.resource.status_code
  end

end
