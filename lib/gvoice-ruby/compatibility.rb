# -*- encoding: utf-8 -*-

if RUBY_VERSION < '1.9'
  class Symbol
    def to_proc
      proc { |obj, *args| obj.send(self, *args) }
    end
  end
  
  class Array
    def sort_by!(&given_proc)
      if block_given?
        self.sort! { |a,b| given_proc.call(a) <=> given_proc.call(b) }
      else
        raise ArgumentError "No valid proc object created from argument."
      end
    end
  end
end
# 
# class Thing
#   def initialize
#     @foo = rand(100)
#   end
#   
#   attr_accessor :foo
# end
# 
# a = []
# 
# 10.times do
#   a << Thing.new
# end
# 
# a.sort_by!(&:foo)
# 
# p a