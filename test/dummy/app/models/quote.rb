# example of a fetchable subclass

class Quote < ActiveRecord::Base
  acts_as_fetchable store: Fetchable::Stores::FileStore.new(
    folder: '/tmp/quotes',
    name_prefix: 'quote' 
  )
end
