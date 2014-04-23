require 'hashie'
require 'net/http'
require 'excon'
require 'byebug'
require 'fetchable/util'
require 'fetchable/fetcher'
require 'fetchable/migration'
require 'fetchable/stores/file_store'
require 'fetchable/schedulers/simple_scheduler'
require 'fetchable/schedulers/decaying_scheduler'

module Fetchable

  extend ActiveSupport::Concern

  module ClassMethods

    cattr_accessor :callbacks, :settings

    self.settings = Hashie::Mash.new
    self.callbacks = Hashie::Mash.new

    %w(before_fetch after_fetch after_fetch_update after_refetch after_fetch_redirect after_fetch_error).each { |event|
      self.callbacks[event]=[]
      define_method(event.to_sym) { |handler| self.callbacks[event] << handler }
    }

  end

  included do
    serialize :redirect_chain
    attr_reader :body
    scope :ready_for_fetch, -> { where('? >= next_fetch_after', DateTime.now).order(:next_fetch_after) }
  end

  def call_callbacks(event)
    self.class.callbacks[event].each { |c| self.send(c) }
  end

  # Convenient shorthands
  def ok? ; self.fail_count==0 ; end
  def failed? ; self.fail_count > 0 ; end
  def redirected_to ; self.redirect_chain.last[:url] if self.redirect_chain ; end

  # Delegating to strategies
  def store_key ; self.class.settings[:store].key_of(self) ; end
  #def ready_for_fetch ; self.class.settings[:scheduler].ready_for_fetch(self.class) ; end

  def fetch(options={})

    self.call_callbacks :before_fetch
    options = Hashie::Mash.new(options.reverse_merge(limit: 5))
    response, options, redirect_chain = Fetchable::Fetcher.deep_fetch(self, self.url, [], options)
    now = DateTime.now
    self.assign_from_rest_response(response, options, redirect_chain, now)

    #byebug
    if scheduler = self.class.settings.scheduler
      self.next_fetch_after = now + scheduler.next_fetch_wait(self)
    end

    if response.status!=304 and store = self.class.settings[:store]
      store.save_content(self, response, options)
    end

    self.call_callbacks_based_on_response(response)
    self.save!

  end
  
  def assign_from_rest_response(response, options, redirect_chain, now)

    #self.status_code = response.code
    #headers = self.class.extract_headers(response)

    self.status_code = response.status
    headers = Hashie::Mash.new(response.headers)
    self.etag = headers.Etag if headers.Etag
    self.last_modified = DateTime.parse(headers['Last-Modified']) if headers['Last-Modified']
    @previous_fingerprint = self.fingerprint
    if response.body.present?
      self.fingerprint = Base64.strict_encode64(Digest::SHA256.new.digest(response.body))
      self.size = response.body.length
      @body = response.body.chomp
    elsif response.status!=304
      self.fingerprint = nil
      self.size = nil
    end
    if redirect_chain.present?
      self.redirect_chain = redirect_chain 
      self.permanent_redirect_url = calculate_permanent_redirect_url
    else
      self.redirect_chain = self.permanent_redirect_url = nil
    end

    if [200,304].include?(response.status)
      self.fail_count = 0
      self.fetched_at = now
      self.refetched_at = now if response.status==304
    else
      self.fail_count ||= 0
      self.fail_count += 1
      self.failed_at = now
    end

    self.tried_at = now
  end

  def call_callbacks_based_on_response(response)
    # normally error would be >= 400, but here it's >= 300 because a final redirect
    # status implies we hit the redirect limit
    self.call_callbacks(:after_fetch_error) if self.status_code >= 300
    self.call_callbacks(:after_refetch) if self.status_code==304
    self.call_callbacks(:after_fetch_update) if self.fingerprint!=@previous_fingerprint
    self.call_callbacks(:after_fetch_redirect) if self.redirect_chain.present?
    self.call_callbacks(:after_fetch)
  end

  def calculate_permanent_redirect_url
    the_url = nil
    if self.redirect_chain
      self.redirect_chain.each { |redirect|
        break if redirect[:status_code]==302
        the_url = redirect[:url]
      }
    end
    the_url
  end

end
