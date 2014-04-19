require_relative './test_helper'

class EventTest < ActiveSupport::TestCase

  def setup
    @dog = images(:dog)
  end

  def test_callback_sequence
    @dog.expects(:handle_before_fetch)
    @dog.expects(:handle_after_fetch)
    @dog.fetch
  end

end
