class Document < ActiveRecord::Base

  include Fetchable

  settings.scheduler = Fetchable::Schedulers::SimpleScheduler.new(
    success_wait: 1.hour,
    fail_wait: 2.days
  )
=begin
  (
    success_wait: 1.week,
    recurring_problem_wait: 10.minutes,
    problem_tries: 3,
    initial_error_wait: 1.hour,
    error_decay: 2
  )
=end

  settings.store = Fetchable::Stores::FileStore.new(
    folder: '/tmp/testing',
    name_prefix: 'doco' 
  )

  before_fetch :handle_before_fetch
  after_fetch :handle_after_fetch
  after_refetch :handle_refetch
  after_fetch_update :handle_fetch_update
  after_fetch_redirect :handle_fetch_redirect
  after_fetch_error :handle_fetch_error

  # We're just using these for mocks
  def handle_before_fetch ; end
  def handle_after_fetch ; end
  def handle_refetch ; end
  def handle_fetch_update ; end
  def handle_fetch_error ; end
  def handle_fetch_redirect ; end

end
