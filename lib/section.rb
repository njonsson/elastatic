require 'yaml'
require 'lib/elastatic/titleize_extension'

class Section
  
  CONFIG_FILENAME = '_config.yml'
  
  class << self
    
    def find_in_root
      Section.new.find_subsections
    end
    
  end
  
  attr_reader :path
  
  def initialize(path=nil)
    @path = path
  end
  
  def find_subsections
    sections = []
    Dir.glob File.join(*[path, '*-content'].compact) do |d|
      next unless File.directory?(d)
      sections << Section.new(d)
    end
    sections
  end
  
  def title
    title_from_config_file = fetch_title_from_config_file
    return title_from_config_file if title_from_config_file
    return nil unless path
    File.basename(path).gsub(/-content$/, '').titleize
  end
  
private
  
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
