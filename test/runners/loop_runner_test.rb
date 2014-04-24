require_relative '../test_helper'

class LoopRunnerTest < ActiveSupport::TestCase

  def setup
    3.times { |count| 
      Resource.create(url: Dummy::test_feed(time: count))
    }
  end

  def test_loop
    Fetchable::Runners::LoopRunner.new.run(Resource)
  end
end
