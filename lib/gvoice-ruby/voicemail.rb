# -*- encoding: utf-8 -*-
module GvoiceRuby
  class Voicemail < Struct.new(:id, :start_time, :display_number, :display_start_date_time, :display_start_time, :relative_start_time, :is_read, :starred, :labels, :from, :to, :transcript, :file)
    #attr_accessor :id, :start_time, :display_number, :display_start_date_time, :display_start_time, :relative_start_time, :is_read, :labels, :from, :to, :transcript, :file
    #
    #def initialize
    #  
    #end
  end
end