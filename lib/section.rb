require 'yaml'
unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/elastatic/require_relative_extension")
end
require_relative 'elastatic/inflections_extension'
unless Symbol.respond_to?(:to_proc)
  require_relative 'elastatic/to_proc_extension'
end
require_relative 'entry'
require_relative 'site'

class Section
  
  CONFIG_FILENAME = '_config.yml' unless const_defined?('CONFIG_FILENAME')
  
  attr_reader :path
  
  def initialize(attributes={})
    @path = attributes[:path].freeze
  end
  
  def build!
    entries.each &:build!
    subsections.each &:build!
    publish_nonsection_subdirectories!
    self
  end
  
  def build_path
    return Site::OUTPUT_DIRECTORY unless path
    File.join Site::OUTPUT_DIRECTORY,
              path.gsub(/-content([\/\\]+)/, '\1').gsub(/-content$/, '')
  end
  
  def empty?
    return false unless entries.empty?
    subsections.all? &:empty?
  end
  
  def entries
    collect_from_filesystem :entries do |f|
      Entry.new :path => f, :section => self
    end
  end
  
  def index
    entries.detect &:index?
  end
  
  def subsections
    collect_from_filesystem :sections do |d|
      Section.new :path => d
    end
  end
  
  def nonsection_subdirectories
    collect_from_filesystem :other
  end
  
  def title
    title_from_config_file = fetch_title_from_config_file
    return title_from_config_file if title_from_config_file
    File.basename(File.expand_path(path ? build_path : '.')).humanize.titleize
  end
  
private
  
  def collect_from_filesystem(type)
    objects = []
    collector = Proc.new do |entry|
      if block_given?
        objects << yield(entry)
      else
        objects << entry
      end
    end
    Dir.glob File.join(*[path, '[^_]*'].compact) do |entry|
      case type
        when :entries
          if File.file?(entry)
            collector.call entry
          end
        when :sections
          if File.directory?(entry) && (entry =~ /-content$/)
            collector.call entry
          end
        else
          if File.directory?(entry) && (entry =~ /-content$/).nil?
            collector.call entry
          end
      end
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
  
  def publish_nonsection_subdirectories!
    nonsection_subdirectories.each do |d|
      Kernel.system %Q(mkdir -p "#{build_path}")
      Kernel.system %Q(cp -R "#{d}" "#{build_path}/")
    end
  end
  
end
