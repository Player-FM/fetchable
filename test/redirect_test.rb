require_relative './test_helper'

class RedirectTest < ActiveSupport::TestCase

  def test_redirect_chain_is_null_for_regular_call
    greeting.fetch
    assert_nil greeting.redirect_chain
  end

  def test_redirect_chain_is_followed_and_captured
    greeting.url = Dummy::test_file(name: 'greeting.txt', redirect: '2')
    greeting.fetch
    assert_equal 200, greeting.status_code
    assert_equal Dummy::test_file(name: 'greeting.txt', redirect: '0'), greeting.redirected_to
    assert_nil greeting.permanent_redirect_url
    assert_equal 2, greeting.redirect_chain.size
    assert_equal Dummy::test_file(name: 'greeting.txt', redirect: '1'), greeting.redirect_chain.first[:url]
    assert_equal 302, greeting.redirect_chain.first[:status_code]
  end

  def test_permanent_redirect
    greeting.url = Dummy::test_file(name: 'greeting.txt', permanent_redirect: '2')
    greeting.fetch
    assert_equal 200, greeting.status_code
    assert_equal Dummy::test_file(name: 'greeting.txt', permanent_redirect: '0'), greeting.redirected_to
    assert_equal Dummy::test_file(name: 'greeting.txt', permanent_redirect: '0'), greeting.permanent_redirect_url
    assert_equal 2, greeting.redirect_chain.size
  end

  def test_relative_redirect
    greeting.url = Dummy::test_file(name: 'greeting.txt', relative_redirect: '2')
    greeting.fetch
    assert_equal 200, greeting.status_code
    assert_equal Dummy::test_file(name: 'greeting.txt', relative_redirect: '0'), greeting.redirected_to
  end

end
