require_relative '../test_helper'

class LoopRunnerTest < ActiveSupport::TestCase

  def setup
    10.times { |feed| 
      Resource.create(url: 'http://testdata.player.fm/?time=30')
    }
  end

  def test_loop
    Fetchable::Runners::LoopRunner.new.run(Resource)
  end
end
