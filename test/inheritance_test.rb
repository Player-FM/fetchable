require_relative './test_helper'

class InheritanceTest < ActiveSupport::TestCase

  QUOTE_URL = Dummy::test_file(name: 'aristotle.txt', last_modified: '_', etag: '_')

  def test_subclass_is_fetchable
    quote = HistoricalQuote.new(url: QUOTE_URL)
    quote.expects(:handle_historical_quote)
    quote.fetch
    assert_equal 200, quote.status_code
    assert quote.store_key =~ /^\/tmp\/historical_quotes/
    assert File.exist?(quote.store_key), "no file at #{quote.store_key}"
  end

  # see https://coderwall.com/p/xhcmbg
  def test_subclass_callbacks_dont_bleed_into_superclass
    quote = Quote.new(url: QUOTE_URL)
    quote.expects(:handle_historical_quote).never
    quote.fetch
  end

  def test_subsclass_callbacks_dont_bleed_into_superclass
    quote = Quote.new(url: QUOTE_URL)
    assert_equal '/tmp/quotes', quote.fetchable_settings[:store].folder
    historical_quote = HistoricalQuote.new(url: QUOTE_URL)
    assert_equal '/tmp/historical_quotes', historical_quote.fetchable_settings[:store].folder
  end

end
