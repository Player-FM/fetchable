require 'hashie'

module Fetchable
  class Resource < ActiveRecord::Base

    belongs_to :fetchable, polymorphic: true

    def self.extract_headers(response)
      Hashie::Mash.new(response.to_hash.each_with_object({}) { |(header_type, header_value), nice_headers|
        nice_headers[header_type.underscore] = header_value[0]
      })
    end

    def assign_from_rest_response(response, options, redirect_chain)
      #self.status_code = response.code
      #headers = self.class.extract_headers(response)
      self.status_code = response.status
      headers = Hashie::Mash.new(response.headers)
      self.etag = headers.Etag if headers.Etag
      self.last_modified = DateTime.parse(headers['Last-Modified']) if headers['Last-Modified']
      self.size = (response.body.length if response.body)
      self.signature = (Base64.strict_encode64(Digest::SHA256.new.digest(response.body)) if response.body)
      self.redirected_to = redirect_chain.last
    end

  end
end
