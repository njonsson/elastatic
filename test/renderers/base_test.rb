require 'test/unit'
require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
require_relative '../../vendor/mocha'
require_relative '../../lib/elastatic/friendly_tests_extension'
require_relative '../../lib/renderers/base'

class Renderers::BaseTest < Test::Unit::TestCase
  
  def setup
    @base_renderer = Renderers::Base
  end
  
  test 'should be immutable' do
    assert_raise NoMethodError do
      @base_renderer.supported_file_extensions = %w(foo)
    end
    assert_raise TypeError do
      @base_renderer.supported_file_extensions << 'foo'
    end
  end
  
  test 'should be its own canonical class' do
    assert_same @base_renderer, @base_renderer.canonical_class
  end
  
  test 'should have no supported file extensions' do
    assert_equal [], @base_renderer.supported_file_extensions
  end
  
  test 'should return the source when rendering' do
    assert_equal 'foo', @base_renderer.render('foo')
  end
  
  test 'should not touch the scope option when rendering' do
    @base_renderer.render 'foo', :scope => mock
  end
  
end
