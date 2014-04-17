require 'test_helper'

class ResourcePersistenceTest < ActiveSupport::TestCase

  DOG_ETAG = '"cee1cac995540c33e06d792e077297bd31e7e504"'
  DOG_LAST_MODIFIED = 1391848200
  DOG_SIZE = 20997
  DOG_SIGNATURE = 'siNHt2UDgfCAwhga/x8nQm3HKXKSrVrLk1U+GtyvYrA='

  def setup
    @dog = images(:dog)
  end

  def test_first_fetch_creates_resource
    assert_nil @dog.resource
    @dog.fetch
    assert_not_nil @dog.resource
    assert_equal @dog, @dog.resource.fetchable
  end

  def test_resource_attribs
    @dog.fetch
    assert_equal 200, @dog.resource.status_code
    assert_equal DOG_ETAG, @dog.resource.etag
    assert_equal DOG_SIZE, @dog.resource.size
    assert_equal DOG_SIGNATURE, @dog.resource.signature
  end

  def test_blank_resource_attribs
    @dog.url = Dummy::test_file(etag: '_', last_modified: '_')
    @dog.fetch
    assert_equal 200, @dog.resource.status_code
    assert_equal nil, @dog.resource.etag
    assert_equal nil, @dog.resource.last_modified
  end

end
