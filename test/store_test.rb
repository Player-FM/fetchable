require_relative './test_helper'

class StoreTest < ActiveSupport::TestCase

  GREETING_CONTENT = 'ohai'

  def test_first_fetch_creates_resource
    greeting.fetch
    expected_path = greeting.store_key
    assert_equal "/tmp/testing/doco#{Fetchable::Util.encode greeting.id}.txt", expected_path
    assert File.exist?(expected_path), "no file at #{expected_path}"
    assert_equal GREETING_CONTENT, open(expected_path).read.chomp
  end

  def test_image
    Resource.fetchable_settings.store = Fetchable::Stores::FileStore.new
    place = Resource.create(url: 'http://placehold.it/100x100.jpg')
    place.fetch
    expected_path = "#{Rails.root}/public/fetchables/res#{Fetchable::Util.encode(place.id)}.jpeg"
    assert_equal expected_path, place.store_key
    assert File.exist?(expected_path), "no file at #{expected_path}"
  end


end
