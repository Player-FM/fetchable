class HistoricalQuote < Quote

  fetch_changed :handle_historical_quote
  fetchable_options store: Fetchable::Stores::FileStore.new(
    folder: '/tmp/historical_quotes',
    name_prefix: 'quote' 
  )

  def historical_quote ; end

end
