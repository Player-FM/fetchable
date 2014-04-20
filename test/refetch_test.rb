require_relative './test_helper'

class RefetchTest < ActiveSupport::TestCase

  def setup
    dog.fetch
    assert_not_nil dog.resource.etag
  end

  def test_no_mementos_means_full_refetch
    dog.url = Dummy::test_file(name: 'greeting.txt', etag: '_', last_modified: '_')
    dog.fetch
    assert_equal 200, dog.resource.status_code
  end

  def test_etag_means_minimal_refetch
    dog.url = Dummy::test_file(name: 'greeting.txt', last_modified: '_')
    dog.fetch
    assert_equal 304, dog.resource.status_code
  end

  def test_modified_since_means_minimal_refetch
    dog.url = Dummy::test_file(name: 'greeting.txt', etag: '_')
    dog.fetch
    assert_equal 304, dog.resource.status_code
  end

end
