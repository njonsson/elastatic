require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
require_relative { '../../lib/elastatic/friendly_tests_extension' }
require_relative { '../../lib/renderers/haml' }

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
    expected_html = <<-end_expected_html
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Foo</title>
  </head>
  <body>
    <h1>Foo</h1>
    <p>Foo bar baz.</p>
  </body>
</html>
    end_expected_html
    haml = <<-end_haml
%html{html_attrs}
  %head
    %title Foo
  %body
    %h1 Foo
    
    %p Foo bar baz.
    end_haml
    assert_equal expected_html, @haml.render(haml)
  end
  
  test 'should render Haml using the scope option' do
    expected_html = <<-end_expected_html
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
  <body>
    <h1>this is a test</h1>
  </body>
</html>
    end_expected_html
    haml = <<-end_haml
%html{html_attrs}
  %body
    %h1= test_message
    end_haml
    scope = Object.new
    def scope.test_message
      'this is a test'
    end
    actual_html = @haml.render(haml, :scope => scope)
    assert_equal expected_html, actual_html
  end
  
end
