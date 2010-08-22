# -*- encoding: utf-8 -*-
module GvoiceRuby
  class Sms < Struct.new(:id, :start_time, :display_number, :display_start_date_time, :display_start_time, :relative_start_time, :is_read, :starred, :labels, :from, :to, :text)
   #attr_accessor :id, :start_time, :display_number, :display_start_date_time, :display_start_time, :relative_start_time, :is_read, :labels, :from, :to, :text
   #
   #def initialize
   #end
  end
end