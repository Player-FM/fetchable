require 'hashie'

module Fetchery

  class Resource < ActiveRecord::Base

    belongs_to :fetchery, polymorphic: true

    def self.settings
      @@settings ||= Hashie::Mash.new(
        store: Fetchery::Store::FileStore.new
      )
    end

    def settings
      self.class.settings
    end

    def path
      "#{settings.content_folder}/#{settings.content_prefix}#{Fetchery::Util.encode(fetchery.id)}.txt"
    end

    def self.extract_headers(response)
      Hashie::Mash.new(response.to_hash.each_with_object({}) { |(header_type, header_value), nice_headers|
        nice_headers[header_type.underscore] = header_value[0]
      })
    end

    def fetch(options={})
      fetchery.call_callbacks :before_fetch
      options = Hashie::Mash.new(options.reverse_merge(limit: 5))
      deep_fetch(fetchery.url, [], options)
      fetchery.call_callbacks :after_fetch
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
        redirect_chain << URI.parse(new_url).to_s
        deep_fetch new_url, redirect_chain, options
      else
        self.assign_from_rest_response(resp, options, redirect_chain)
        self.save!
        settings[:store].save_content(self, resp, options) if settings[:store]
      end

    end

    def assign_from_rest_response(response, options, redirect_chain)

      #self.status_code = response.code
      #headers = self.class.extract_headers(response)

      self.status_code = response.status
      headers = Hashie::Mash.new(response.headers)
      self.etag = headers.Etag if headers.Etag
      self.last_modified = DateTime.parse(headers['Last-Modified']) if headers['Last-Modified']
      self.size = (response.body.length if response.body)
      self.fingerprint = (Base64.strict_encode64(Digest::SHA256.new.digest(response.body)) if response.body)
      self.redirected_to = redirect_chain.last

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

  end

end
