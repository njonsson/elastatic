module Renderers; end

class Renderers::Base
  
  class << self
    
    def canonical_class
      self
    end
    
    def render(source, options={})
      source
    end
    
    def supported_file_extensions
      @supported_file_extensions ||= [].freeze
    end
    
  end
  
end
