class HistoricalQuote < Quote

  after_fetch_change :handle_historical_quote

  def historical_quote ; end

end
