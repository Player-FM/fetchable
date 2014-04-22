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

end
