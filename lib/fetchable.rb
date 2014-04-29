require 'hashie'
require 'net/http'
require 'excon'
require 'byebug'
require 'validate_url'
project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/fetchable/**/*.rb', &method(:require))

module Fetchable

  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_fetchable(options={})
      @fetchable_settings = Hashie::Mash.new(options)
      @fetchable_callbacks = Hashie::Mash.new
      %w(before_fetch after_fetch after_fetch_change after_refetch after_fetch_redirect after_fetch_error).each { |event|
        @fetchable_callbacks[event]=[]
        define_singleton_method(event.to_sym) { |handler| self.fetchable_callbacks[event] << handler }
      }
    end
    def fetchable_settings ; @fetchable_settings; end
    def fetchable_callbacks ; @fetchable_callbacks; end
    def ready_for_fetch
      where('? >= next_fetch_after', DateTime.now).order(:next_fetch_after)
    end
  end

  included do

    serialize :redirect_chain
    validate :url, :validate_url_string
    attr_reader :body
    def validate_url_string
      if url.present? && url !~ URI::regexp
        errors.add(:url, "isn't a valid URL")
      end
    end

    # Convenient shorthands
    def ok? ; self.fetch_fail_count==0 ; end
    def failed? ; self.fetch_fail_count > 0 ; end
    def redirected_to ; self.redirect_chain.last[:url] if self.redirect_chain ; end
    def content_type ; self.received_content_type || self.inferred_content_type ; end
    def changed? ; self.fingerprint_changed? ; end
    def purge_mementos
      self.update_attributes etag: nil, last_modified: nil
    end

    def call_fetchable_callbacks(event)
      vetoed = false
      self.class.fetchable_callbacks[event].each { |callback|
        if self.send(callback)==false
          vetoed = true
          break
        end
      }
      vetoed
    end

    # Delegating to strategies
    def store_key ; self.class.fetchable_settings[:store].key_of(self) ; end
    #def ready_for_fetch ; self.class.settings[:scheduler].ready_for_fetch(self.class) ; end

    def fetch(options={})

      self.call_fetchable_callbacks :before_fetch
      options = Hashie::Mash.new(options.reverse_merge(limit: 5))
      response, options, redirect_chain = Fetchable::Fetcher.deep_fetch(self, self.url, [], options)
      now = DateTime.now
      self.assign_from_rest_response(response, options, redirect_chain, now)

      if scheduler = self.class.fetchable_settings.scheduler
        self.next_fetch_after = now + scheduler.next_fetch_wait(self)
      end

      if response.status!=304 and store = self.class.fetchable_settings[:store]
        store.save_content(self, response, now, options)
      end

      self.call_fetchable_callbacks_based_on_response(response)
      self.save!

    end
    
    def assign_from_rest_response(response, options, redirect_chain, now)

      #self.status_code = response.code
      #headers = self.class.extract_headers(response)

      self.status_code = response.status
      headers = Hashie::Mash.new(response.headers)

      self.received_content_type = headers['Content-Type']
      url_path = Addressable::URI.parse(self.url).path
      types = MIME::Types.type_for(url_path)
      self.inferred_content_type = types.first.content_type if types.present?

      self.etag = headers.Etag if headers.Etag
      self.last_modified = DateTime.parse(headers['Last-Modified']) if headers['Last-Modified']
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
        self.fetch_fail_count = 0
        self.fetch_succeeded_at = now
      else
        self.fetch_fail_count ||= 0
        self.fetch_fail_count += 1
      end

      if self.fingerprint_changed?
        self.fetch_changed_at = now
      end

      self.fetch_tried_at = now
    end

    def call_fetchable_callbacks_based_on_response(response)
      # normally error would be >= 400, but here it's >= 300 because a final redirect
      # status implies we hit the redirect limit
      self.call_fetchable_callbacks(:after_fetch_error) if self.status_code >= 300
      self.call_fetchable_callbacks(:after_refetch) if self.status_code==304
      if self.fingerprint_changed?
        change_vetoed = self.call_fetchable_callbacks(:after_fetch_change) 
        self.fetch_changed_at = self.fetch_changed_at_was if change_vetoed # revert change if vetoed
      end
      self.call_fetchable_callbacks(:after_fetch_redirect) if self.redirect_chain.present?
      self.call_fetchable_callbacks(:after_fetch)
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

end

class ActiveRecord::Base
  include Fetchable
end
