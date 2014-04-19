require 'fetchable/resource'
require 'net/http'
require 'excon'
require 'byebug'

module Fetchable

  extend ActiveSupport::Concern

  included do
    has_one :resource, class_name: 'Fetchable::Resource', foreign_key: 'fetchable_id', as: :fetchable
  end

  module ClassMethods

    cattr_accessor :callbacks

    def add_callback(event, handler)
      # ensure
      self.callbacks||=Hashie::Mash.new
      self.callbacks[event]||=[]
      # add
      self.callbacks[event] << handler
    end

    %w(before_fetch after_fetch).each { |callback|
      define_method(callback.to_sym) { |handler| add_callback(callback.to_sym, handler) }
    }

  end

  module InstanceMethods
  end

  def fetch(options={})
    self.resource ||= Fetchable::Resource.create(fetchable_id: self.id)
    self.resource.fetchable = self # in case self changed recently
    self.resource.fetch(options)
  end

  def call_callbacks(event)
    self.class.callbacks[event].each { |c| self.send(c) }
  end
    
end
