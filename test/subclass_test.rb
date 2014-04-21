require_relative './test_helper'

class SubclassTest < ActiveSupport::TestCase

  def test_subclass
    doc = Document.create url: Dummy::test_file(name: 'farewell.txt')
  end

end
