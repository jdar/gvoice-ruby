# -*- encoding: utf-8 -*-

Pathname.class_eval do
  def ancestor(num)
    temp = self
    num.downto(0) do
      temp = temp.parent
    end
    return temp
  end unless method_defined?(:ancestor)
end

if RUBY_VERSION > '1.9'
  module GvoiceRuby
    class Call
     alias_method :orig_display_start_date_time, :display_start_date_time 
     
     def display_start_date_time # New Date class in Ruby 1.9.2 only accepts strictly formatted strings Date.parse
      if self.send(:caller).first.include?('inbox_parser')
        orig_display_start_date_time
      else
        # Capture the original date string and parse into month, day, year variables
        # warn "#{self.send(:caller)}"
      
        orig_display_start_date_time.match(/^(\d)\/(\d{1,2})\/(\d{2})\s(.+)\z/)
        # month = $1
        # day   = $2
        year  = "20" + $3
        # warn "Month is: #{month}\nDay is: #{day}\nYear is: #{year}"
        "#{year}-#{$1}-#{$2} #{$4}"
      end
     end
    end
  end
end

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
