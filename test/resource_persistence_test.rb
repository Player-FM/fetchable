require 'test_helper'
require 'timecop'

class ResourcePersistenceTest < ActiveSupport::TestCase

  DOG_ETAG = '"0ce56d0a6e9baa0c5d170001592c9b9c65d19276"'
  DOG_LAST_MODIFIED = 1391848200
  DOG_SIZE = 5
  DOG_FINGERPRINT = 'Wab4pWDcin+Z9HBXC8wQD1DkFZIvv3GievNMVjDPIzo='

  def test_first_fetch_creates_resource
    assert_nil dog.resource
    dog.fetch
    assert_not_nil dog.resource
    assert dog.resource.fetchable==dog
  end

  def test_resource_attribs
    Timecop.freeze(now) do
      dog.fetch
      assert_equal 200, dog.resource.status_code
      assert_equal DOG_ETAG, dog.resource.etag
      assert_equal DOG_SIZE, dog.resource.size
      assert_equal DOG_FINGERPRINT, dog.resource.fingerprint
      assert_equal 0, dog.resource.fail_count
      assert_equal now, dog.resource.tried_at
      assert_equal now, dog.resource.fetched_at
      assert_equal now+1.day, dog.resource.next_try_after
    end
  end

  def test_blank_resource_attribs
    dog.url = Dummy::test_file(etag: '_', last_modified: '_')
    dog.fetch
    assert_equal 200, dog.resource.status_code
    assert_equal nil, dog.resource.etag
    assert_equal nil, dog.resource.last_modified
  end

  def test_blank_resource_attribs
    Timecop.freeze(now) do
      dog.url = Dummy::test_file(name: 'does-not-exist')
      dog.fetch
      assert_equal 404, dog.resource.status_code
      assert_equal now, dog.resource.tried_at
      assert_equal now, dog.resource.failed_at
      assert_equal now+1.hour, dog.resource.next_try_after
    end
  end

end
