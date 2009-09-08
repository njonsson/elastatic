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
    
    test 'should return path with trailing "-content" removed from all directory names in a deep section path' do
      assert_equal '_output/foo/bar/baz/bat',
                   Section.new(:path => 'foo-content/bar/baz-content/bat').build_path
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
    
    test 'should return nil if no entries' do
      @section.stubs(:entries).returns []
      assert_nil @section.index
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
    
    test 'should return nil if no entry is an index' do
      @entries.each do |e|
        e.stubs(:index?).returns false
      end
      assert_nil @section.index
    end
    
  end
  
  class Empty < Test::Unit::TestCase
    
    def setup
      @section = Section.new
      @section.stubs(:entries).returns []
      @section.stubs(:subsections).returns []
    end
    
    test 'should get entries' do
      @section.expects(:entries).returns []
      @section.empty?
    end
    
    class ForASectionHavingEntries < Empty
      
      def setup
        super
        @entries = [Entry.new(:path => 'foo.html.haml', :section => @section),
                    Entry.new(:path => 'bar.html.haml', :section => @section),
                    Entry.new(:path => 'baz.html.haml', :section => @section)]
        @section.stubs(:entries).returns @entries
      end
      
      test 'should not get subsections' do
        @section.expects(:subsections).never
        @section.empty?
      end
      
      test 'should return false' do
        assert_equal false, @section.empty?
      end
      
    end
    
    class ForASectionHavingNoEntries < Empty
      
      def setup
        super
        @section.stubs(:entries).returns []
        @section.stubs(:subsections).returns []
      end
      
      test 'should get subsections' do
        @section.expects(:subsections).returns []
        @section.empty?
      end
      
      class AndNoSubsections < ForASectionHavingNoEntries
        
        test 'should return true' do
          assert_equal true, @section.empty?
        end
        
      end
      
      class AndHavingSubsections < ForASectionHavingNoEntries
        
        def setup
          super
          @subsections = [Section.new(:path => 'dir/goes/here/foo'),
                          Section.new(:path => 'dir/goes/here/bar'),
                          Section.new(:path => 'dir/goes/here/baz')]
          @section.stubs(:subsections).returns @subsections
        end
        
        test 'should detect the first non-empty subsection' do
          @subsections[0].expects(:empty?).returns true
          @subsections[1].expects(:empty?).returns false
          @subsections[2].expects(:empty?).never
          @section.empty?
        end
        
        test 'should return false if at least one subsection is not empty' do
          @subsections[0].stubs(:empty?).returns true
          @subsections[1].stubs(:empty?).returns false
          assert_equal false, @section.empty?
        end
        
        test 'should return true if all subsections are empty' do
          @subsections.each do |s|
            s.stubs(:empty?).returns true
          end
          assert_equal true, @section.empty?
        end
        
      end
      
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
        Dir.stubs(:glob).yields 'foo-content'
        File.stubs(:directory?).returns true
      end
      
      test 'should search for content directories in root' do
        Dir.expects(:glob).with('[^_]*-content').yields 'foo-content'
        @section.subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('foo-content').returns true
        @section.subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        section = Section.new
        Section.expects(:new).with(:path => 'foo-content').returns section
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
        
        test 'should construct the title from the expanded path of the current directory' do
          File.expects(:expand_path).with('.').returns '/Users/bob'
          @section.title
        end
        
        test 'should return the humanized and titleized name of the current directory' do
          File.stubs(:expand_path).with('.').returns '/Users/bob'
          assert_equal 'Bob', @section.title
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
          
          test 'should expand the path of the current directory' do
            File.expects(:expand_path).with('.').returns '/Users/bob'
            @section.title
          end
          
          test 'should return the humanized and titleized name of the current directory' do
            File.stubs(:expand_path).with('.').returns '/Users/bob'
            assert_equal 'Bob', @section.title
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
        Dir.stubs(:glob).yields 'dir/goes/here/foo-content'
        File.stubs(:directory?).returns true
      end
      
      test 'should search for content directories in path' do
        Dir.expects(:glob).
            with('dir/goes/here/[^_]*-content').
            yields 'foo-content'
        @section.subsections
      end
      
      test 'should verify that filesystem entries are directories' do
        File.expects(:directory?).with('dir/goes/here/foo-content').returns true
        @section.subsections
      end
      
      test 'should instantiate a new Section for each content directory' do
        Section.expects(:new).
                with(:path => 'dir/goes/here/foo-content').
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
        
        test 'should construct the title from the expanded path' do
          File.expects(:expand_path).
               with('_output/dir/goes/here').
               returns '/Users/bob/dir/goes/here'
          @section.title
        end
        
        test 'should return the humanized and titleized name of the path' do
          File.stubs(:expand_path).
               with('_output/dir/goes/here').
               returns '/Users/bob/dir/goes/here'
          assert_equal 'Here', @section.title
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
          
          test 'should expand the path' do
            File.expects(:expand_path).
                 with('_output/dir/goes/here').
                 returns '/Users/bob/dir/goes/here'
            @section.title
          end
          
          test 'should return the humanized and titleized name of the path' do
            File.stubs(:expand_path).
                 with('_output/dir/goes/here').
                 returns '/Users/bob/dir/goes/here'
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
