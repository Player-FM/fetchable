# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require 'mocha/test_unit'
require 'timecop'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

class ActiveSupport::TestCase

  #set_fixture_class resources: Fetchable::Resource
  fixtures :all

  def greeting
    #documents(:greeting)
    documents(:greeting)
  end

  def now
    DateTime.new(2000, 1, 1, 0, 0, 0)
  end

end
