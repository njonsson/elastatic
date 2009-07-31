module Elastatic; end

module Elastatic::TitleizeExtension
  
  def titleize
    self.gsub /\b([a-z])/ do |initial|
      initial.upcase
    end
  end
  
end

String.class_eval do
  include Elastatic::TitleizeExtension
end
