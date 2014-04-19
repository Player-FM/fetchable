require 'test_helper'

class TrackingTest < ActiveSupport::TestCase

  def setup
    @dog = images(:dog)
  end

  def test_successful
    @dog.fetch
  end

end
