class Document < ActiveRecord::Base

  include Fetchable

  before_fetch :handle_before_fetch
  after_fetch :handle_after_fetch
  after_refetch :handle_refetch
  after_fetch_redirect :handle_fetch_redirect
  after_fetch_error :handle_fetch_error

  # We're just using these for mocks
  def handle_before_fetch ; end
  def handle_after_fetch ; end
  def handle_refetch ; end
  def handle_fetch_error ; end
  def handle_fetch_redirect ; end

end
