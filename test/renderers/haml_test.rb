require 'test/unit'
require 'lib/elastatic/friendly_tests_extension'
require 'vendor/mocha'
require 'lib/renderers/haml'

class Renderers::HamlTest < Test::Unit::TestCase
  
  def setup
    @haml = Renderers::Haml
  end
  
  test 'should be immutable' do
    assert_raise NoMethodError do
      @haml.supported_file_extensions = %w(foo)
    end
    assert_raise TypeError do
      @haml.supported_file_extensions << 'foo'
    end
  end
  
  test 'should be its own canonical class' do
    assert_same @haml, @haml.canonical_class
  end
  
  test 'should support rendering of .haml files' do
    assert_equal %w(haml), @haml.supported_file_extensions
  end
  
  test 'should render Haml to the expected HTML' do
    expected = <<-end_html
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Foo</title>
  </head>
  <body>
    <h1>Foo</h1>
    <p>Foo bar baz.</p>
  </body>
</html>
    end_html
    actual = @haml.render <<-end_haml
%html{html_attrs}
  %head
    %title Foo
  %body
    %h1 Foo
    
    %p Foo bar baz.
    end_haml
    assert_equal expected, actual
  end
  
end
