require_relative './test_helper'

class EventTest < ActiveSupport::TestCase

  def test_callback_sequence
    greeting.expects(:handle_before_fetch)
    greeting.expects(:handle_after_fetch)
    greeting.fetch
  end

end
