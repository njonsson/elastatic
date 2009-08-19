require 'vendor/haml'

module Renderers; end

class Renderers::Haml
  
  class << self
    
    def canonical_class
      self
    end
    
    def render(haml_source, haml_options={})
      haml_options = {:attr_wrapper => '"'}.merge(haml_options)
      Haml::Engine.new(haml_source, haml_options).render
    end
    
    def supported_file_extensions
      @supported_file_extensions ||= %w(haml).freeze
    end
    
  end
  
end
