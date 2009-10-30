module Elastatic; end

module Elastatic::InflectionsExtension
  
  def camelize
    self.gsub(/(^\w|_+\w)/) do |initial|
      initial.gsub('_', '').upcase
    end
  end
  
  def humanize
    self.gsub(/[a-z0-9][_\-][a-z0-9]/i) do |word_juncture|
      word_juncture.gsub(/[_\-]/, ' ')
    end
  end
  
  def titleize
    self.gsub(/\b[a-z]/) do |initial|
      initial.upcase
    end
  end
  
end

String.class_eval do
  include Elastatic::InflectionsExtension
end
