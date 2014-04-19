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

  def test_after_initial_fetch
    #@dog.expects(:after_initial_fetch).expects(*args)
    #@dog.fetch
  end

end
