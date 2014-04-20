require_relative './test_helper'

class ContentPersistenceTest < ActiveSupport::TestCase

  GREETING_CONTENT = 'ohai'

  def test_first_fetch_creates_resource
    Fetchable::Resource.settings.content_store = Fetchable::Resource::FILE_STORE
    Fetchable::Resource.settings.content_folder = '/tmp/testing' 
    Fetchable::Resource.settings.content_prefix = 'doco' 
    greeting.fetch
    expected_path = "/tmp/testing/doco#{Fetchable::Util.encode greeting.id}.txt"
    assert File.exist?(expected_path), "no file at #{expected_path}"
    assert_equal GREETING_CONTENT, open(expected_path).read.chomp
  end

end
