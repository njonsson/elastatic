unless private_methods.include?(:require_relative)
  require File.expand_path("#{File.dirname __FILE__}/../elastatic/require_relative_extension")
end
require_relative '../../vendor/haml'

module Renderers; end

class Renderers::Haml
  
  class << self
    
    def canonical_class
      self
    end
    
    def render(haml_source, options={})
      options = {:attr_wrapper => '"'}.merge(options)
      Haml::Engine.new(haml_source, options).render(options[:scope]).
                                             gsub('&', '&amp;').
                                             gsub('<', '&lt;').
                                             gsub '>', '&gt;'
    end
    
    def supported_file_extensions
      @supported_file_extensions ||= %w(haml).freeze
    end
    
  end
  
end
