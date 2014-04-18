require_relative './test_helper'

class RedirectTest < ActiveSupport::TestCase

  def setup
    @dog = images(:dog)
    #@dog.fetch
    #assert_equal 200, @dog.resource.status_code
    #assert_not_nil @dog.resource.etag
  end

  def test_redirect_chain_is_followed_and_captured
    @dog.url = Dummy::test_file(name: 'dog.jpg', redirect: '2')
    @dog.fetch
    assert_equal 200, @dog.resource.status_code
    assert_equal Dummy::test_file(name: 'dog.jpg', redirect: '0'), @dog.resource.redirected_to
  end

  def test_relative_redirect
    @dog.url = Dummy::test_file(name: 'dog.jpg', relative_redirect: '2')
    @dog.fetch
    assert_equal 200, @dog.resource.status_code
    assert_equal Dummy::test_file(name: 'dog.jpg', relative_redirect: '0'), @dog.resource.redirected_to
  end

end
