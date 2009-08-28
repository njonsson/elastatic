require 'test/unit'
require File.expand_path("#{File.dirname __FILE__}/../lib/elastatic/require_relative_extension")
require_relative { '../vendor/mocha' }
require_relative { '../lib/elastatic/friendly_tests_extension' }
require_relative { '../lib/entry' }
require_relative { '../lib/renderers' }

class EntryTest < Test::Unit::TestCase
  
  module ClassMethods
    
    class New < Test::Unit::TestCase
      
      test 'should set path attribute' do
        assert_equal 'dir/goes/here/foo',
                     Entry.new(:path => 'dir/goes/here/foo').path
      end
      
      test 'should set section attribute' do
        mock_section = mock('Section')
        assert_equal mock_section, Entry.new(:section => mock_section).section
      end
      
    end
    
  end
  
  def setup
    @mock_section = mock('Section')
    @entry = Entry.new(:path => 'dir/goes/here/foo', :section => @mock_section)
  end
  
  test 'should be immutable' do
    assert_raise NoMethodError do
      @entry.path = 'bar'
    end
    assert_raise TypeError do
      @entry.path.gsub! 'foo', 'bar'
    end
    assert_raise NoMethodError do
      @entry.section = mock('Section')
    end
  end
  
  class Source < EntryTest
    
    def setup
      super
      File.stubs(:read).returns 'content goes here'
    end
    
    test 'should read the file' do
      File.expects(:read).with('dir/goes/here/foo').returns 'content goes here'
      @entry.source
    end
    
    test 'should return the source' do
      assert_equal 'content goes here', @entry.source
    end
    
  end
  
  class BuildAndBuildPath < EntryTest
    
    def setup
      super
      @mock_section.stubs(:build_path).returns '_output/dir/goes/here'
      @entry.stubs(:source).returns 'content goes here'
      Renderers.stubs(:choose).returns nil
      Kernel.stubs :system
      @mock_file = mock('File')
      File.stubs(:open).yields @mock_file
      @mock_file.stubs :print
    end
    
    test 'should obtain the build path of the section when sent build!' do
      @mock_section.expects(:build_path).returns '_output/dir/goes/here'
      @entry.build!
    end
    
    test 'should obtain the build path of the section when sent build_path' do
      @mock_section.expects(:build_path).returns '_output/dir/goes/here'
      @entry.build_path
    end
    
    test 'should read the source when sent build!' do
      @entry.expects(:source).with().returns 'content goes here'
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
        @mock_file.expects(:print).with 'content goes here'
        @entry.build!
      end
      
      test 'should return the expected path constructed from the section build path when sent build_path' do
        assert_equal '_output/dir/goes/here/foo', @entry.build_path
      end
      
    end
    
    class WithOneRenderableAndOneUnrenderableFileExtension < BuildAndBuildPath
      
      def setup
        super
        @entry.stubs(:path).returns 'dir/goes/here/foo.html.haml'.freeze
        @mock_haml_renderer = mock('Renderers::Haml')
        Renderers.stubs(:choose).
                  with('haml').
                  returns @mock_haml_renderer
        @mock_haml_renderer.stubs(:render).returns 'rendered content goes here'
        Renderers.stubs(:choose).
                  with('html').
                  returns nil
      end
      
      test 'should choose a renderer for the first file extension when sent build!' do
        Renderers.expects(:choose).with('haml').returns @mock_haml_renderer
        @entry.build!
      end
      
      test 'should use the first renderer when sent build!' do
        @mock_haml_renderer.expects(:render).
                            with('content goes here',
                                 @entry,
                                 :filename => '_output/dir/goes/here/foo.html.haml').
                            returns 'rendered content goes here'
        @entry.build!
      end
      
      test 'should choose a renderer for the second file extension when sent build!' do
        Renderers.expects(:choose).with('html').returns nil
        @entry.build!
      end
      
      test 'should open the output file for write access when sent build!' do
        File.expects(:open).
             with('_output/dir/goes/here/foo.html', 'w').
             yields @mock_file
        @entry.build!
      end
      
      test 'should write the rendered content to the output subdirectory when sent build!' do
        @mock_file.expects(:print).with 'rendered content goes here'
        @entry.build!
      end
      
      test 'should return the expected path constructed from the section build path when sent build_path' do
        assert_equal '_output/dir/goes/here/foo.html', @entry.build_path
      end
      
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
        @entry.expects(:index?).returns false
        @entry.title
      end
      
      test 'should construct the title from the build_path' do
        @entry.expects(:build_path).
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
        @mock_section.stubs(:title).returns 'Here'
      end
      
      test 'should check if the entry is an index' do
        @entry.expects(:index?).returns true
        @entry.title
      end
      
      test "should use the section's title" do
        @mock_section.expects(:title).returns 'Here'
        @entry.title
      end
      
      test "should return the section's title" do
        assert_equal 'Here', @entry.title
      end
      
    end
    
  end
  
end
