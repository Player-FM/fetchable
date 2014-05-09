class Document < ActiveRecord::Base

  acts_as_fetchable store: Fetchable::Stores::FileStore.new(
    folder: '/tmp/testing',
    name_prefix: 'doco' 
  ),
  scheduler: Fetchable::Schedulers::SimpleScheduler.new(
    success_wait: 1.hour,
    fail_wait: 2.hours
  )

  fetch_started :handle_fetch_started
  fetch_changed :handle_fetch_changed
  fetch_changed_and_ended :handle_fetch_changed_and_ended
  fetch_redirected :handle_fetch_redirected
  fetch_failed :handle_fetch_failed
  fetch_ended :handle_fetch_ended

  # We're just using these for mocks
  def handle_fetch_started ; end
  def handle_fetch_changed ; end
  def handle_fetch_changed_and_ended ; end
  def handle_fetch_redirected ; end
  def handle_fetch_failed ; end
  def handle_fetch_ended ; end

end
