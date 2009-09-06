require 'test/unit'
require File.expand_path("#{File.dirname __FILE__}/../lib/elastatic/require_relative_extension")
require_relative { '../vendor/mocha' }
require_relative { '../lib/elastatic/friendly_tests_extension' }
require_relative { '../lib/section' }
require_relative { '../lib/entry' }

module SectionTest
  
  module ClassMethods
    
    class New < Test::Unit::TestCase
      
      test 'should set path attribute to nil when sent with no arguments' do
        assert_nil Section.new.path
      end
      
      test 'should set path attribute to :path argument' do
        assert_equal 'foo', Section.new(:path => 'foo').path
      end
      
    end
    
  end
  
  class BuildPath < Test::Unit::TestCase
    
    test 'should return the expected path for a shallow section path' do
      assert_equal '_output/foo', Section.new(:path => 'foo').build_path
    end
    
    test 'should return the expected path for a deep section path' do
      assert_equal '_output/foo/bar/baz',
                   Section.new(:path => 'foo/bar/baz').build_path
    end
    
  end
  
  class Index < Test::Unit::TestCase
    
    def setup
      @section = Section.new
      @entries = [Entry.new(:path => 'foo.html.haml', :section => @section),
                  Entry.new(:path => 'bar.html.haml', :section => @section),
                  Entry.new(:path => 'baz.html.haml', :section => @section)]
      @entries[0].stubs(:index?).returns false
      @entries[1].stubs(:index?).returns true
      @entries[2].stubs(:index?).returns true
      @section.stubs(:entries).returns @entries
    end
    
    test 'should get entries' do
      @section.expects(:entries).returns @entries
      @section.index
    end
    
    test 'should detect first index' do
      @entries[0].expects(:index?).returns false
      @entries[1].expects(:index?).returns true
      @entries[2].expects(:index?).never
      @section.index
    end
    
    test 'should return first detected index' do
      assert_equal @entries[1], @section.index
    end
    
  end
  
  class ForRoot < Test::Unit::TestCase
    
    def setup
      @section = Section.new
    end
    
    test 'should have nil path' do
      assert_nil @section.path
    end
    
    test 'should have expected build_path' do
      assert_equal '_output', @section.build_path
    end
    
    class Build < ForRoot
      
      def setup
        super
        @subsection = Section.new(:path => 'foo')
        @section.stubs(:subsections).returns [@subsection]
        @entry = Entry.new(:path => 'foo/bar.html.haml', :section => @section)
        @entry.stubs(:build!).returns @entry
        @section.stubs(:entries).returns [@entry]
      end
      
      test 'should find subsections' do
        @section.expects(:subsections).returns [@subsection]
        @section.build!
      end
      
      test 'should build each subsection' do
        @subsection.expects(:build!).returns @subsection
        @section.build!
      end
      
      test 'should find entries' do
        @section.expects(:entries).returns [@entry]
        @section.build!
      end
      
      test 'should build each entry' do
        @entry.expects(:build!).returns @entry
        @section.build!
      end
      
      test 'should return itself' do
        assert_same @section, @section.build!
      end
      
    end
    
    class Entries < ForRoot
      
      def setup
        super
        Dir.stubs(:glob).yields 'index.html.haml'
        File.stubs(:file?).returns true
      end
      
      test 'should search for filesystem entries in root' do
        Dir.expects(:glob).with('[^_]*').yields 'index.html.haml'
        @section.entries
      end
      
      test 'should verify that filesystem entries are files' do
        File.expects(:file?).with('index.html.haml').returns true
        @section.entries
      end
      
      test 'should instantiate a new Entry for each entry file' do
        Entry.expects(:new).
              with(:path => 'index.html.haml', :section => @section).
              returns @entry
        @section.entries
      end
      
      test 'should not instantiate a new Entry for non-files' do
        File.stubs(:file?).returns false
        Entry.expects(:new).never
        @section.entries
      end
      
      test 'should return the instantiated Entry objects' do
        entry = Entry.new(:path => 'index.html.haml', :section => @section)
        Entry.stubs(:new).returns entry
        assert_equal [entry], @section.entries
      end
      
    end
    
    class Subsections < ForRoot
      
      def setup
        super
        Dir.stubs(:glob).yields 'foo'
        File.stubs(:directory?).returns true
      end
      
      test 'should search for content directories in root' do
        Dir.expects(:glob).with('[^_]*').yields 'foo'
        @section.subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('foo').returns true
        @section.subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        section = Section.new
        Section.expects(:new).with(:path => 'foo').returns section
        @section.subsections
      end
      
      test 'should not instantiate a new Section for non-directories' do
        File.stubs(:directory?).returns false
        Section.expects(:new).never
        @section.subsections
      end
      
      test 'should return the instantiated Section objects' do
        subsection = Section.new
        Section.stubs(:new).returns subsection
        assert_equal [subsection], @section.subsections
      end
      
    end
    
    class Title < ForRoot
      
      def setup
        super
        File.stubs(:exist?).returns false
      end
      
      test 'should look for existence of section configuration file in root' do
        File.expects(:exist?).with('_config.yml').returns false
        @section.title
      end
      
      class WithoutSectionConfigurationFile < Title
        
        test 'should return nil' do
          assert_nil @section.title
        end
        
      end
      
      class WithSectionConfigurationFile < Title
        
        def setup
          super
          File.stubs(:exist?).returns true
          File.stubs(:read).returns ''
          YAML.stubs(:load).returns false
        end
        
        test 'should read section configuration file in root' do
          File.expects(:read).with('_config.yml').returns ''
          @section.title
        end
        
        class LackingTitleOption < WithSectionConfigurationFile
          
          test 'should return nil' do
            assert_nil @section.title
          end
          
        end
        
        class HavingTitleOption < WithSectionConfigurationFile
          
          def setup
            super
            File.stubs(:read).returns 'title: foo'
            YAML.stubs(:load).returns({'title' => 'foo'})
          end
          
          test 'should interpret section configuration file as YAML' do
            YAML.expects(:load).with('title: foo').returns({'title' => 'foo'})
            @section.title
          end
          
          test 'should return configured title' do
            assert_equal 'foo', @section.title
          end
          
        end
        
      end
      
    end
    
  end
  
  class ForDeepDirectory < Test::Unit::TestCase
    
    def setup
      @section = Section.new(:path => 'dir/goes/here')
    end
    
    test 'should have expected path' do
      assert_equal 'dir/goes/here', @section.path
    end
    
    test 'should have expected build_path' do
      assert_equal '_output/dir/goes/here', @section.build_path
    end
    
    class Build < ForDeepDirectory
      
      def setup
        super
        @entry = Entry.new(:path => 'dir/goes/here/foo.html.haml',
                           :section => @section)
        @section.stubs(:entries).returns [@entry]
        @entry.stubs(:build!).returns @entry
      end
      
      test 'should find entries' do
        @section.expects(:entries).returns [@entry]
        @section.build!
      end
      
      test 'should build each entry' do
        @entry.expects(:build!).returns @entry
        @section.build!
      end
      
      test 'should return itself' do
        assert_same @section, @section.build!
      end
      
    end
    
    class Entries < ForDeepDirectory
      
      def setup
        super
        Dir.stubs(:glob).yields 'dir/goes/here/index.html.haml'
        File.stubs(:file?).returns true
        @entry = Entry.new(:path => 'dir/goes/here/index.html.haml',
                           :section => @section)
      end
      
      test 'should search for filesystem entries in path' do
        Dir.expects(:glob).with('dir/goes/here/[^_]*').yields 'index.html.haml'
        @section.entries
      end
      
      test 'should verify that filesystem entries are files' do
        File.expects(:file?).with('dir/goes/here/index.html.haml').returns true
        @section.entries
      end
      
      test 'should instantiate a new Entry for each entry file' do
        Entry.expects(:new).
              with(:path => 'dir/goes/here/index.html.haml',
                   :section => @section).
              returns @entry
        @section.entries
      end
      
      test 'should not instantiate a new Entry for non-files' do
        File.stubs(:file?).returns false
        Entry.expects(:new).never
        @section.entries
      end
      
      test 'should return the instantiated Entry objects' do
        Entry.stubs(:new).returns @entry
        assert_equal [@entry], @section.entries
      end
      
    end
    
    class Subsections < ForDeepDirectory
      
      def setup
        super
        Dir.stubs(:glob).yields 'dir/goes/here/foo'
        File.stubs(:directory?).returns true
      end
      
      test 'should search for content directories in path' do
        Dir.expects(:glob).
            with('dir/goes/here/[^_]*').
            yields 'dir/goes/here/foo'
        @section.subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('dir/goes/here/foo').returns true
        @section.subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        Section.expects(:new).
                with(:path => 'dir/goes/here/foo').
                returns @subsection
        @section.subsections
      end
      
      test 'should not instantiate a new Section for non-directories' do
        File.stubs(:directory?).returns false
        Section.expects(:new).never
        @section.subsections
      end
      
      test 'should return the instantiated Section objects' do
        subsection = Section.new
        Section.stubs(:new).returns subsection
        assert_equal [subsection], @section.subsections
      end
      
    end
    
    class Title < ForDeepDirectory
      
      def setup
        super
        File.stubs(:exist?).returns false
      end
      
      test 'should look for existence of section configuration file in path' do
        File.expects(:exist?).with('dir/goes/here/_config.yml').returns false
        @section.title
      end
      
      class WithoutSectionConfigurationFile < Title
        
        test 'should construct the title from the build_path' do
          @section.expects(:build_path).returns '_output/dir/goes/here'
          @section.title
        end
        
        test 'should return the humanized and titleized directory name of the build_path' do
          @section.stubs(:build_path).
                   returns '_output/dir/goes/here-there_everywhere.at-once'
          assert_equal 'Here There Everywhere.At Once', @section.title
        end
        
      end
      
      class WithSectionConfigurationFile < Title
        
        def setup
          super
          File.stubs(:exist?).returns true
          File.stubs(:read).returns ''
          YAML.stubs(:load).returns false
        end
        
        test 'should read section configuration file in path' do
          File.expects(:read).with('dir/goes/here/_config.yml').returns ''
          @section.title
        end
        
        class LackingTitleOption < WithSectionConfigurationFile
          
          test 'should return titleized directory name' do
            assert_equal 'Here', @section.title
          end
          
        end
        
        class HavingTitleOption < WithSectionConfigurationFile
          
          def setup
            super
            File.stubs(:read).returns 'title: foo'
            YAML.stubs(:load).returns({'title' => 'foo'})
          end
          
          test 'should interpret section configuration file as YAML' do
            YAML.expects(:load).with('title: foo').returns({'title' => 'foo'})
            @section.title
          end
          
          test 'should return configured title' do
            assert_equal 'foo', @section.title
          end
          
        end
        
      end
      
    end
    
  end
  
end
