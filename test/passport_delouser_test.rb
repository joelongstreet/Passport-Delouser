require 'test_helper'

class PassportDelouserTest < ActiveSupport::TestCase

  def test_to_hash_has_method_dig
    assert Hash.method_defined?(:dig), 'Dig is not defined :('
  end
  
end
