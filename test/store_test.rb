require_relative './test_helper'

class StoreTest < ActiveSupport::TestCase

  GREETING_CONTENT = 'ohai'
  FAREWELL_CONTENT = 'ciao'

  def test_first_fetch_creates_resource
    greeting.fetch
    expected_path = greeting.store_key
    assert_equal "/tmp/testing/0/doco#{Fetchable::Util.encode greeting.id}.txt", expected_path
    assert File.exist?(expected_path), "no file at #{expected_path}"
    assert_equal GREETING_CONTENT, open(expected_path).read.chomp
  end

  def test_refetch_wont_recreate_resource_even_without_mementos
    greeting.url = Dummy::test_file(name: 'hello.txt', last_modified: '_', etag: '_')
    greeting.fetch
    original_mtime = File.mtime(greeting.store_key)
    sleep 1
    greeting.fetch
    assert_equal original_mtime, File.mtime(greeting.store_key)
  end

  def test_refetch_will_recreate_resource_if_different
    greeting.url = Dummy::test_file(name: 'hello.txt', last_modified: '_', etag: '_')
    greeting.fetch
    original_mtime = File.mtime(greeting.store_key)
    sleep 1
    greeting.url = Dummy::test_file(name: 'farewell.txt', last_modified: '_', etag: '_')
    greeting.fetch
    assert_not_equal original_mtime, File.mtime(greeting.store_key)
    assert_equal FAREWELL_CONTENT, open(greeting.store_key).read.chomp
  end

  def test_image
    Resource.fetchable_settings.store = Fetchable::Stores::FileStore.new
    place = Resource.create(url: 'http://placehold.it/100x100.jpg')
    place.update_column(:id, 1234567)
    assert_equal place.reload.id, 1234567
    place.fetch
    expected_path = "#{Rails.root}/public/fetchables/567/res#{Fetchable::Util.encode(1234567)}.jpeg"
    assert_equal expected_path, place.store_key
    assert File.exist?(expected_path), "no file at #{expected_path}"
  end

  def test_without_sharding
    Resource.fetchable_settings.store = Fetchable::Stores::FileStore.new(subfolder_amount: 0)
    place = Resource.create(url: 'http://placehold.it/100x100.jpg')
    place.update_column(:id, 1234567)
    place.fetch
    expected_path = "#{Rails.root}/public/fetchables/res#{Fetchable::Util.encode(1234567)}.jpeg"
    assert_equal expected_path, place.store_key
    assert File.exist?(expected_path), "no file at #{expected_path}"
  end

end
