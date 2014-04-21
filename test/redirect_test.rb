require_relative './test_helper'

class RedirectTest < ActiveSupport::TestCase

  def test_redirect_chain_is_followed_and_captured
    greeting.url = Dummy::test_file(name: 'greeting.txt', redirect: '2')
    greeting.fetch
    assert_equal 200, greeting.status_code
    assert_equal Dummy::test_file(name: 'greeting.txt', redirect: '0'), greeting.redirected_to
  end

  def test_relative_redirect
    greeting.url = Dummy::test_file(name: 'greeting.txt', relative_redirect: '2')
    greeting.fetch
    assert_equal 200, greeting.status_code
    assert_equal Dummy::test_file(name: 'greeting.txt', relative_redirect: '0'), greeting.redirected_to
  end

end
