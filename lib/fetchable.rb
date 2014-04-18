require 'fetchable/resource'
require 'net/http'
require 'excon'
require 'byebug'

module Fetchable

  def self.included(base)
    base.extend(ClassMethods)
    base.has_one :resource, class_name: 'Fetchable::Resource', foreign_key: 'fetchable_id', as: :fetchable
  end

  module ClassMethods
    #def 
  end

  def fetch(options={})
    options = Hashie::Mash.new(options.reverse_merge(limit: 5))
    deep_fetch(self.url, [], options)
  end
    
  private

  # http://shadow-file.blogspot.co.uk/2009/03/handling-http-redirection-in-ruby.html
  def deep_fetch(url, redirect_chain, options)

    # Set up call
    self.resource ||= Fetchable::Resource.create(fetchable_id: self.id)
    headers = Hashie::Mash.new
    headers['if-none-match'] = self.resource.etag if self.resource.etag.present?
    headers['if-modified-since'] = self.resource.last_modified.rfc2822 if self.resource.last_modified.present?

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
      self.resource.assign_from_rest_response(resp, options, redirect_chain)
      self.resource.save!
      self.save!
    end
  end

  # http://shadow-file.blogspot.co.uk/2009/03/handling-http-redirection-in-ruby.html
  def _deep_fetch(url, redirect_chain, options)

    # Set up call
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.hostname, uri.port)
    path = uri.path.present? ? uri.path : '/'
    http.open_timeout = 10
    http.read_timeout = 10

    req = Net::HTTP::Get.new(path)
    if uri.instance_of? URI::HTTPS
      http.use_ssl=true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    self.resource ||= Fetchable::Resource.create(fetchable_id: self.id)
    req['if-none-match'] = self.resource.etag if self.resource.etag.present?
    req['if-modified-since'] = self.resource.last_modified.rfc2822 if self.resource.last_modified.present?

    # Make the call

    resp = http.request(req)

    if resp==Net::HTTPRedirection and redirect_chain.size <= options.limit
      new_url = resp['location']
      if URI.parse(new_url).relative?
        new_url = uri + resp['location']
      end
      redirect_chain << new_url
      deep_fetch new_url, limit-1, options
    else
      self.resource.assign_from_rest_response(resp, options, redirect_chain)
      self.resource.save!
      self.save!
    end

  end

end
