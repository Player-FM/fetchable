require 'fetchable/resource'
require 'net/http'
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
    self.resource ||= Fetchable::Resource.create(fetchable_id: self.id)
    #response = RestClient.get self.url, headers

    req = Net::HTTP::Get.new(self.url)
    req['if-none-match'] = self.resource.etag if self.resource.etag.present?
    req['if-modified-since'] = self.resource.last_modified.rfc2822 if self.resource.last_modified.present?
    uri = URI(self.url)
    resp = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    self.resource.assign_from_rest_response(resp)
    self.resource.save!
    self.save!
  end

end
