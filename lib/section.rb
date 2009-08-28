require 'yaml'
require File.expand_path("#{File.dirname __FILE__}/elastatic/require_relative_extension")
require_relative { 'elastatic/inflections_extension' }
require_relative { 'elastatic/to_proc_extension' }
require_relative { 'entry' }
require_relative { 'site' }

class Section
  
  CONFIG_FILENAME = '_config.yml' unless const_defined?('CONFIG_FILENAME')
  
  attr_reader :path
  
  def initialize(path=nil)
    @path = path.freeze
  end
  
  def build!
    entries.each &:build!
    self
  end
  
  def build_path
    return Site::OUTPUT_DIRECTORY unless path
    File.join Site::OUTPUT_DIRECTORY,
              path.gsub(/-content([\/\\]+)/, '\1').gsub(/-content$/, '')
  end
  
  def entries
    return collect_from_filesystem(:pattern => '[^_]*', :file? => true) do |f|
      Entry.new :path => f, :section => self
    end
  end
  
  def index
    entries.detect &:index?
  end
  
  def subsections
    return collect_from_filesystem(:pattern => '*-content',
                                   :directory? => true) do |d|
      Section.new d
    end
  end
  
  def title
    title_from_config_file = fetch_title_from_config_file
    return title_from_config_file if title_from_config_file
    return nil unless path
    File.basename(build_path).humanize.titleize
  end
  
private
  
  def collect_from_filesystem(options={})
    objects = []
    Dir.glob File.join(*[path, options[:pattern]].compact) do |entry|
      next if (options.include?(:file?)      && (File.file?(entry)      != options[:file?])) ||
              (options.include?(:directory?) && (File.directory?(entry) != options[:directory?]))
      objects << yield(entry)
    end
    objects
  end
  
  def fetch_config_from_file
    config_file_full_path = File.join(*[path, CONFIG_FILENAME].compact)
    return nil unless File.exist?(config_file_full_path)
    YAML.load File.read(config_file_full_path)
  end
  
  def fetch_title_from_config_file
    options = fetch_config_from_file
    return nil unless options && options.kind_of?(Hash)
    options['title']
  end
  
end
