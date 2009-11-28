require 'test/unit'
unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/../../lib/elastatic/require_relative_extension")
end
require_relative '../../vendor/mocha'
require_relative '../../lib/elastatic/assertions_extension'
require_relative '../../lib/elastatic/friendly_tests_extension'
require_relative '../../lib/entry'
require_relative '../../lib/renderers'
require_relative '../../lib/section'

class EntryTest < Test::Unit::TestCase
  
  module ClassMethods
    
    class New < Test::Unit::TestCase
      
      test 'should set path and section attributes' do
        section = Section.new
        entry = Entry.new(:path => 'dir/goes/here/foo', :section => section)
        assert_equal 'dir/goes/here/foo', entry.path
        assert_equal section, entry.section
      end
      
      test 'should raise ArgumentError if sent without :path argument' do
        assert_raise ArgumentError do
          Entry.new :section => Section.new
        end
      end
      
      test 'should raise ArgumentError if sent without :section argument' do
        assert_raise ArgumentError do
          Entry.new :path => 'dir/goes/here/foo'
        end
      end
      
    end
    
  end
  
  def setup
    @section = Section.new(:path => 'dir/goes/here')
    @entry   = Entry.new(:path => 'dir/goes/here/foo', :section => @section)
  end
  
  test 'should be immutable' do
    assert_raise NoMethodError do
      @entry.path = 'bar'
    end
    assert_unchanged '@entry.path' do
      @entry.path.gsub! 'foo', 'bar'
    end
    assert_raise NoMethodError do
      @entry.section = Section.new
    end
  end
  
  class Source < EntryTest
    
    def setup
      super
      File.stubs(:read).returns '%content goes here'
    end
    
    test 'should read the file' do
      File.expects(:read).
           with('dir/goes/here/foo').
           returns '%content goes here'
      @entry.source
    end
    
    test 'should return the source' do
      assert_equal '%content goes here', @entry.source
    end
    
  end
  
  class BuildAndBuildPath < EntryTest
    
    def setup
      super
      @section.stubs(:build_path).returns '_output/dir/goes/here'
      @entry.stubs(:source).returns '%content goes here'
      Kernel.stubs :system
      @mock_file = mock('File')
      File.stubs(:open).yields @mock_file
      @mock_file.stubs :print
    end
    
    test 'should obtain the build path of the section when sent build!' do
      @section.expects(:build_path).with().returns '_output/dir/goes/here'
      @entry.build!
    end
    
    test 'should read the source when sent build!' do
      @entry.expects(:source).with().returns '%content goes here'
      @entry.build!
    end
    
    test 'should ensure that the output subdirectory exists when sent build!' do
      Kernel.expects(:system).with 'mkdir -p "_output/dir/goes/here"'
      @entry.build!
    end
    
    test 'should return itself when sent build!' do
      assert_same @entry, @entry.build!
    end
    
    class WithNoFileExtension < BuildAndBuildPath
      
      test 'should choose a renderer for an empty file extension when sent build!' do
        Renderers.expects(:choose).with('').returns nil
        @entry.build!
      end
      
      test 'should open the output file for write access when sent build!' do
        File.expects(:open).
             with('_output/dir/goes/here/foo', 'w').
             yields @mock_file
        @entry.build!
      end
      
      test 'should write the source to the output subdirectory when sent build!' do
        @mock_file.expects(:print).with '%content goes here'
        @entry.build!
      end
      
      test 'should return the expected path constructed from the section build path when sent build_path' do
        assert_equal '_output/dir/goes/here/foo', @entry.build_path
      end
      
    end
    
    class WithOneRenderableAndOneUnrenderableFileExtension < BuildAndBuildPath
      
      def setup
        super
        def @entry.path
          'dir/goes/here/foo.html.haml'
        end
      end
      
      test 'should choose a renderer for each of the file extensions when sent build!' do
        Renderers.expects(:choose).with('haml').returns Renderers::Haml
        Renderers.expects(:choose).with('html').returns nil
        @entry.build!
      end
      
      test 'should use the first renderer when sent build!' do
        Renderers::Haml.expects(:render).
                        with('%content goes here',
                             :scope => @entry,
                             :filename => '_output/dir/goes/here/foo.html.haml').
                        returns '<content>goes here</content>'
        @entry.build!
      end
      
      test 'should open the output file for write access when sent build!' do
        File.expects(:open).
             with('_output/dir/goes/here/foo.html', 'w').
             yields @mock_file
        @entry.build!
      end
      
      test 'should write the rendered content to the output subdirectory when sent build!' do
        @mock_file.expects(:print).with "&lt;content&gt;goes here&lt;/content&gt;\n"
        @entry.build!
      end
      
      test 'should return the expected path constructed from the section build path when sent build_path' do
        assert_equal '_output/dir/goes/here/foo.html', @entry.build_path
      end
      
    end
    
  end
  
  class Href < EntryTest
    
    def setup
      super
      @entry.stubs(:build_path).returns '_output/dir/../goes/../here/foo.html'
    end
    
    test "should use the build_path" do
      @entry.expects(:build_path).returns '_output/dir/../goes/../here/foo.html'
      @entry.href
    end
    
    test 'should return the expected path' do
      assert_equal 'here/foo.html', @entry.href
    end
    
  end
  
  class Index < EntryTest
    
    test 'should return false for a nonindex Entry' do
      @entry.stubs(:path).returns 'dir/goes/here/index-is-elsewhere.html.haml'
      assert_equal false, @entry.index?
    end
    
    test 'should return true for an index Entry with file extensions' do
      @entry.stubs(:path).returns 'dir/goes/here/index.html.haml'
      assert_equal true, @entry.index?
    end
    
    test 'should return true for an index Entry without file extensions' do
      @entry.stubs(:path).returns 'dir/goes/here/index'
      assert_equal true, @entry.index?
    end
    
  end
  
  class Title < EntryTest
    
    def setup
      super
      @entry.stubs(:build_path).returns '_output/dir/goes/here/foo-bar_baz.txt.html'
    end
    
    class ForNonindex < Title
      
      def setup
        super
        @entry.stubs(:index?).returns false
      end
      
      test 'should check if the entry is an index' do
        @entry.expects(:index?).with().returns false
        @entry.title
      end
      
      test 'should construct the title from the build_path' do
        @entry.expects(:build_path).
               with().
               returns '_output/dir/goes/here/foo-bar_baz.txt.html'
        @entry.title
      end
      
      test 'should return the humanized and titleized basename of the build_path' do
        assert_equal 'Foo Bar Baz', @entry.title
      end
      
    end
    
    class ForIndex < Title
      
      def setup
        super
        @entry.stubs(:index?).returns true
        @section.stubs(:title).returns 'Here'
      end
      
      test 'should check if the entry is an index' do
        @entry.expects(:index?).with().returns true
        @entry.title
      end
      
      test "should use the section's title" do
        @section.expects(:title).with().returns 'Here'
        @entry.title
      end
      
      test "should return the section's title" do
        assert_equal 'Here', @entry.title
      end
      
    end
    
  end
  
end
