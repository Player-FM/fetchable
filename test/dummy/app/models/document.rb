class Document < ActiveRecord::Base

  include Fetchery
  
  before_fetch :handle_before_fetch
  after_fetch :handle_after_fetch

  def handle_before_fetch
  end

  def handle_after_fetch
  end

end
