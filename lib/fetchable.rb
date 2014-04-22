require 'hashie'
require 'net/http'
require 'excon'
require 'byebug'
require 'fetchable/util'
require 'fetchable/migration'
require 'fetchable/store/file_store'

module Fetchable

  extend ActiveSupport::Concern

  module ClassMethods

    cattr_accessor :callbacks, :settings

    self.settings = Hashie::Mash.new
    self.callbacks=Hashie::Mash.new

    %w(before_fetch after_fetch after_fetch_update after_refetch after_fetch_redirect after_fetch_error).each { |event|
      self.callbacks[event]=[]
      define_method(event.to_sym) { |handler| self.callbacks[event] << handler }
    }

  end

  included do
    serialize :redirect_chain
  end

  def fetch(options={})
    self.resource ||= Fetchable::Resource.create(fetchable_id: self.id)
    self.resource.fetchable = self # in case self changed recently
    self.resource.fetch(options)
  end

  def call_callbacks(event)
    self.class.callbacks[event].each { |c| self.send(c) }
  end

  def path
    "#{settings.content_folder}/#{settings.content_prefix}#{Fetchable::Util.encode(self.id)}.txt"
  end
  
  def fetch(options={})
    self.call_callbacks :before_fetch
    options = Hashie::Mash.new(options.reverse_merge(limit: 5))
    response = deep_fetch(self.url, [], options)
    call_callbacks_based_on_response(response)
  end

  # http://shadow-file.blogspot.co.uk/2009/03/handling-http-redirection-in-ruby.html
  def deep_fetch(url, redirect_chain, options)

    # Set up call
    headers = Hashie::Mash.new
    headers['if-none-match'] = self.etag if self.etag.present?
    headers['if-modified-since'] = self.last_modified.rfc2822 if self.last_modified.present?

    resp = Excon.get(url, headers: headers)

    if [301,302].include?(resp.status) and redirect_chain.size <= options.limit
      new_url = resp.headers['location']
      if URI.parse(new_url).relative?
        old_url = Addressable::URI.parse(url)
        port = '' if [old_url.port, old_url.scheme] == [80, 'http'] || [old_url.port, old_url.scheme] == [443, 'https']
        new_url = "#{old_url.scheme}://#{old_url.host}:#{port}#{resp.headers['location']}"
      end
      # Use URI.parse() instead of raw URL because raw URL string includes
      # unnecessary :80 and :443 port number
      redirect_chain << { url: URI.parse(new_url).to_s, status_code: resp.status }
      deep_fetch new_url, redirect_chain, options
    else
      self.assign_from_rest_response(resp, options, redirect_chain)
      self.save!
      if resp.status!=304
        store = self.class.settings[:store]
        store.save_content(self, resp, options) if store
      end
    end

    resp

  end

  def assign_from_rest_response(response, options, redirect_chain)

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

    now = DateTime.now
    if [200,304].include?(response.status)
      self.fail_count = 0
      self.fetched_at = now
      self.refetched_at = now if response.status==304
      self.next_try_after = now+1.day
    else
      self.fail_count ||= 0
      self.fail_count += 1
      self.failed_at = now
      self.next_try_after = now+1.hour
    end

    self.tried_at = now

  end

  def call_callbacks_based_on_response(response)
    self.call_callbacks(:after_fetch_error) if self.status_code >= 400
    self.call_callbacks(:after_refetch) if self.status_code==304
    self.call_callbacks(:after_fetch_update) if self.fingerprint!=@previous_fingerprint
    self.call_callbacks(:after_fetch_redirect) if self.redirect_chain.present?
    self.call_callbacks(:after_fetch)
  end

  def redirected_to
    self.redirect_chain.last[:url] if self.redirect_chain
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
