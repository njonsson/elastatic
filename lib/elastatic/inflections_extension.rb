module Elastatic; end

module Elastatic::InflectionsExtension
  
  def camelize
    self.gsub /(^(\w)|_+(\w))/ do |initial|
      initial.gsub('_', '').upcase
    end
  end
  
  def titleize
    self.gsub /\b([a-z])/ do |initial|
      initial.upcase
    end
  end
  
end

String.class_eval do
  include Elastatic::InflectionsExtension
end
