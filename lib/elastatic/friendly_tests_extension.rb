require 'test/unit'

module Elastatic; end

module Elastatic::FriendlyTestsExtension
  
  module ClassMethods
    
    def test(description, &block)
      test_name = "test_#{description.strip}"
      test_location = caller.first.gsub(/^\.\//, '')
      block ||= Proc.new do
        $stdout.puts "\n*** PENDING at #{test_location}: #{description}"
      end
      define_method test_name, &block
    end
    
  end
  
  def self.included(other_module)
    other_module.extend ClassMethods
  end
  
end

Test::Unit::TestCase.class_eval do
  include Elastatic::FriendlyTestsExtension
end
