require 'hashie'
require 'net/http'
require 'excon'
project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + '/fetchable/**/*.rb', &method(:require))

module Fetchable

  extend ActiveSupport::Concern

  module ClassMethods

    def acts_as_fetchable(options={})

      # class_attribute usage modelled on acts_as_commentable: bit.ly/1iIj6VA 
      class_attribute :fetchable_settings
      class_attribute :fetchable_callbacks

      self.fetchable_settings = Hashie::Mash.new(options)
      self.fetchable_callbacks = Hashie::Mash.new
      %w(fetch_started fetch_changed fetch_redirected fetch_failed fetch_changed_and_ended fetch_ended).each { |event|
        # This is complicated because we need to make sure subclass will not override superclass attribute
        # See http://apidock.com/rails/Class/class_attribute#1332-To-use-class-attribute-with-a-hash
        # Additionally, our data structure is a hash of lists, so we need some extra fudging around
        define_singleton_method(event.to_sym) { |handler|
          callbacks_for_event = self.fetchable_callbacks[event] || []
          update_to_callbacks = {}
          update_to_callbacks[event] = callbacks_for_event+[handler]
          self.fetchable_callbacks = self.fetchable_callbacks.merge (update_to_callbacks)
        }
      }

    end

    def fetchable_options(options={})
      self.fetchable_settings = self.fetchable_settings.merge(options)
    end

    def ready_for_fetch
      where('? >= next_fetch_after', DateTime.now).order(:next_fetch_after)
    end

  end

  included do

    serialize :redirect_chain
    validate :validate_url_string
    attr_reader :body

    def validate_url_string
      # this includes a check of attributes to avoid problems during migration
      if self.attributes.include?(:url) and url.present? and url !~ URI::regexp
        errors.add(:url, "isn't a valid URL")
      end
    end

    # Convenient shorthands
    def ok? ; self.fetch_fail_count==0 ; end
    def failed? ; self.fetch_fail_count > 0 ; end
    def redirected_to ; self.redirect_chain.last[:url] if self.redirect_chain ; end
    def content_type ; self.received_content_type || self.inferred_content_type ; end
    # this will force a fresh call
    def purge_call_mementos ; self.update_attributes(etag: nil, last_modified: nil) ; end
    # this will not just force a fresh call, but also force change handlers to be called even if the response is still the same
    def purge_mementos ; self.update_attributes(etag: nil, last_modified: nil, fingerprint: nil) ; end

    def call_fetchable_callbacks(event)
      vetoed = false
      if callbacks_for_this_event = self.class.fetchable_callbacks[event]
        callbacks_for_this_event.each { |callback|
          if self.send(callback)==false
            vetoed = true
            break
          end
        }
      end
      vetoed
    end

    # Delegating to strategies
    def store_key ; self.class.fetchable_settings[:store].key_of(self) ; end
    #def ready_for_fetch ; self.class.settings[:scheduler].ready_for_fetch(self.class) ; end

    def fetch(options={})

      now = DateTime.now

      begin

        self.call_fetchable_callbacks :fetch_started

        options = Hashie::Mash.new(redirect_limit: 5, force: false).merge(options)
        self.purge_mementos if options.force

        response, options, redirect_chain = Fetchable::Fetcher.deep_fetch(self, self.url, [], options)
        self.assign_from_rest_response(response, options, redirect_chain, now)

        self.call_fetchable_callbacks_based_on_response(response)
        self_changed = self.fingerprint_changed?
        self.save!

        if response.status!=304 and store = self.class.fetchable_settings[:store]
          store.save_content(self, response, now, options)
        end

        @fetch_result = Hashie::Mash.new(response: response)
        self.call_fetchable_callbacks(:fetch_changed_and_ended) if self_changed
        self.call_fetchable_callbacks(:fetch_ended)

      rescue => ex

        Rails.logger.error("Fetchable error #{ex}\n#{ex.backtrace.join("\n")}")

      end          

      if scheduler = self.class.fetchable_settings.scheduler
        self.update_attributes next_fetch_after: now + scheduler.next_fetch_wait(self)
      end

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
      self.call_fetchable_callbacks(:fetch_failed) if self.status_code >= 300
      if self.fingerprint_changed?
        change_vetoed = self.call_fetchable_callbacks(:fetch_changed) 
        self.fetch_changed_at = self.fetch_changed_at_was if change_vetoed # revert change if vetoed
      end
      self.call_fetchable_callbacks(:fetch_redirected) if self.redirect_chain.present?
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

ActiveRecord::Base.send(:include, Fetchable)
