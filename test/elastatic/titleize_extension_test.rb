require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'lib/elastatic/titleize_extension'

class Elastatic::TitleizeExtensionTest < Test::Unit::TestCase
  
  test 'should capitalize lowercase words' do
    assert_equal 'The Quick, Brown Fox Jumped Over The Lazy Dog',
                 'the quick, brown fox jumped over the lazy dog'.titleize
  end
  
  test 'should not disturb capitals' do
    assert_equal 'HAL Was IBM Shifted By One Letter',
                 'HAL was IBM shifted by one letter'.titleize
  end
  
end
