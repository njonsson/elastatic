module Elastatic; end

module Elastatic::ImmutabilityExtension
  
  module ClassMethods
    
    def immutable(method_name)
      alias_method "#{method_name}_without_immutability", method_name
      define_method "#{method_name}_with_immutability" do |*args|
        return_value = send("#{method_name}_without_immutability", *args)
        return_value.dup rescue return_value
      end
      alias_method method_name, "#{method_name}_with_immutability"
    end
    
  end
  
  def self.included(other_module)
    other_module.extend ClassMethods
  end
  
end

Object.class_eval do
  include Elastatic::ImmutabilityExtension
end
