# coding: utf-8
module GvoiceRuby
  class InboxParser
    
    def initialize
      @smss       = []
      @voicemails = []
      @calls      = []
    end
    
    def parse_page(page_obj)
      doc = Nokogiri::XML.parse(page_obj.body_str)
      
      # p doc
      
      @html_fragment = Nokogiri::HTML::DocumentFragment.parse(doc.to_html)
      
      # p @html_fragment
      
      m = doc.css('json').first.to_s.scan(/CDATA\[(.+)\]\]/).flatten
      
      inbox = JSON.parse(m.first)
      return inbox
    end
    
    def parse_sms_messages(messages, page_fragment = @html_fragment)
      messages.each do |txt|
        if txt[1]['type'].to_i == 2
          next
        else
          txt_obj = Sms.new
          txt_obj.id                      = txt[0]
          txt_obj.start_time              = txt[1]['startTime'].to_i
          txt_obj.is_read                 = txt[1]['isRead']
          txt_obj.display_start_time      = txt[1]['displayStartTime']
          txt_obj.relative_start_time     = txt[1]['relativeStartTime']
          txt_obj.display_number          = txt[1]['displayNumber']
          txt_obj.display_start_date_time = txt[1]['displayStartDateTime']
          txt_obj.labels                  = txt[1]['labels']
          @smss << txt_obj
          @smss.sort_by!(&:start_time) #if @smss.respond_to?(:sort_by!)
        end
      end
      
      @smss.each do |txt_obj|
        page_fragment.css("div.gc-message-sms-row").each do |row|
          if row.css('span.gc-message-sms-from').inner_html.strip! =~ /Me:/
            next
          elsif row.css('span.gc-message-sms-time').inner_html =~ Regexp.new(txt_obj.display_start_time)
            txt_obj.to  = 'Me'
            txt_obj.from = row.css('span.gc-message-sms-from').inner_html.strip!.gsub!(':', '')
            txt_obj.text = row.css('span.gc-message-sms-text').inner_html
            # txt_obj.time = row.css('span.gc-message-sms-time').inner_html
          else
            next
          end
        end
      end
    end
  
    def parse_voicemail_messages(messages, page_fragment = @html_fragment)
      # p messages
      messages.each do |msg|
        if msg[1]['type'].to_i == 2
          vm_obj = Voicemail.new
          vm_obj.id                      = msg[0]
          vm_obj.start_time              = msg[1]['startTime'].to_i
          vm_obj.is_read                 = msg[1]['isRead']
          vm_obj.display_start_time      = msg[1]['displayStartTime']
          vm_obj.relative_start_time     = msg[1]['relativeStartTime']
          vm_obj.display_number          = msg[1]['displayNumber']
          vm_obj.display_start_date_time = msg[1]['displayStartDateTime']
          vm_obj.labels                  = msg[1]['labels']
          @voicemails << vm_obj
          @voicemails.sort_by!(&:start_time)
        else
          next
        end
      end
      
      @voicemails.each do |vm_obj|
        page_fragment.css('table.gc-message-tbl').each do |row|
          if row.css('span.gc-message-time').text =~ Regexp.new(vm_obj.display_start_date_time)
            vm_obj.to         = 'Me'
            vm_obj.from       = row.css('a.gc-under.gc-message-name-link').inner_html
            vm_obj.transcript = row.css('div.gc-message-message-display').inner_text.to_s.gsub(/\n/, "").squeeze(" ").strip!
            # vm_obj.time       = row.css('span.gc-message-time').inner_html
          else
            next
          end
        end
      end
    end
  
    def parse_calls(messages, page_fragment = @html_fragment)
      messages.each do |msg|
        call_obj                         = Call.new
        call_obj.id                      = msg[0]
        call_obj.start_time              = msg[1]['startTime'].to_i
        call_obj.is_read                 = msg[1]['isRead']
        call_obj.display_start_time      = msg[1]['displayStartTime']
        call_obj.relative_start_time     = msg[1]['relativeStartTime']
        call_obj.display_number          = msg[1]['displayNumber']
        call_obj.display_start_date_time = msg[1]['displayStartDateTime']
        call_obj.labels                  = msg[1]['labels']
        
        @calls << call_obj
        @calls.sort_by!(&:start_time)
      end
      
      @calls.each do |call_obj|
        page_fragment.css('table.gc-message-tbl').each do |row|
          if row.css('span.gc-message-time').text =~ Regexp.new(call_obj.display_start_date_time)
            call_obj.to           = 'Me'
            call_obj.from         = call_obj.display_number
            # call_obj.from       = row.css('a.gc-under.gc-message-name-link').inner_html
            # call_obj.transcript = row.css('div.gc-message-message-display').inner_text.to_s.gsub(/\n/, "").squeeze(" ").strip!
            # call_obj.time       = row.css('span.gc-message-time').inner_html
          else
            next
          end
        end
      end
    end
  end
end
