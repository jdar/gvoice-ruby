# coding: UTF-8
$:.unshift(File.dirname(__FILE__))
%w[curb nokogiri json sms voicemail user logger compatibility open-uri].each { |lib| require lib }

module GvoiceRuby
  class Client
    include Curl
    
    attr_accessor :page, :unread_counts, :start_times, :smss, :voicemails, :user, :all_messages
    attr_reader :logger
    
    def initialize
      options = GvoiceRuby.load_config
      if options[:google_account_email].nil? || options[:google_account_password].nil?
        raise ArgumentError, "Invalid Google Account username or password provided."
      else          
        @logger        = Logger.new(File.join(File.dirname(__FILE__), '..', '..', 'log', 'gvoice-ruby.log'))
        @user          = User.new(options[:google_account_email], options[:google_account_password])
        @curb_instance = login(options)
        @smss          = []
        @voicemails    = []
        @any_unread    = []
        @start_times   = []
        @unread_counts = {}
        @all_messages  = []
      end
      
      set_rnr_se_token
    end
    
    def any_unread?
      @any_unread
    end
    
    def logged_in?
      !@curb_instance.nil?
    end
    
    def sms(options)
      post_page(:sms, options)
    end
    
    def call(options)
      post_page(:call, options)
    end
    
    def check
      parse_page(fetch_page)
    end
    
    def archive(id) 
      fields = [ PostField.content('messages', id), PostField.content('archive', 1), PostField.content('_rnr_se', @_rnr_se)]
      
      @curb_instance.http_post(fields)
      
      @curb_instance.url = 'https://www.google.com/voice/inbox/archiveMessages/'
      
      @curb_instance.perform
      logger.info "FINISHED POST TO 'https://www.google.com//voice/inbox/mark/': HTTP #{@curb_instance.response_code}"
      return @curb_instance
    end
    
    def mark_as_read(id) 
      fields = [ PostField.content('messages', id), PostField.content('read', 1), PostField.content('_rnr_se', @_rnr_se)]
      
      @curb_instance.http_post(fields)
      
      @curb_instance.url = 'https://www.google.com/voice/inbox/mark/'

      @curb_instance.perform
      logger.info "FINISHED POST TO 'https://www.google.com//voice/inbox/mark/': HTTP #{@curb_instance.response_code}"
      return @curb_instance
    end
    
    def logout
      if logged_in?
        @curb_instance.url = "https://www.google.com/voice/account/signout"
        @curb_instance.perform
        logger.info logger.info "FINISHED LOGOUT #{@curb_instance.url}: HTTP #{@curb_instance.response_code}"
        @curb_instance = nil
      end
      self
    end
    
    private
    def login(options = {})
      @curb_instance = Easy.new('https://www.google.com/accounts/ServiceLoginAuth') do |curl|
        # Google gets mad if you don't fake this...
        curl.headers["User-Agent"] = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.1.2) Gecko/20090729 Firefox/3.5.2"
        # Let's see what happens under the hood
        # curl.verbose = true

        # Google will redirect us a bit
        curl.follow_location = true

        # Google will make sure we retain cookies
        curl.enable_cookies = true

        curl.perform

        # defeat Google's XSRF protection
        doc = Nokogiri::HTML::DocumentFragment.parse(curl.body_str)
        doc.css('div.loginBox table#gaia_table input').each do |input|
          if input.to_s =~ /GALX/
            @galx = input.to_s.scan(/value\="(.+?)"/).flatten!.pop
            # p @galx
          else
          end
        end

        fields = [ PostField.content('continue', options[:continue_url]), #'https://www.google.com/voice'
             PostField.content('GALX', @galx),
             PostField.content('service', options[:google_service]),
             PostField.content('Email', options[:google_account_email]),
             PostField.content('Passwd', options[:google_account_password]) ]

        # puts fields
        curl.http_post(fields)
      end
    end
    
    def post_page(page_type, options)
      # p @curb_instance.methods.sort
      case page_type.id2name
      when /sms/
        fields = [ PostField.content('phoneNumber', options[:phone_number]),
                   PostField.content('text', options[:text]),
                   PostField.content('_rnr_se', @_rnr_se) ]
      when /call/
        fields = [ PostField.content('outgoingNumber', options[:outgoing_number]),
                   PostField.content('forwardingNumber', options[:forwarding_number]),
                   PostField.content('subscriberNumber', 'undefined'),
                   PostField.content('remember', 0),
                   PostField.content('_rnr_se', @_rnr_se) ]
      else
      end
      
      @curb_instance.http_post(fields)
      
      @curb_instance.url = options[:post_url] #"https://www.google.com/voice/call/connect || https://www.google.com/voice/sms/send"
      
      @curb_instance.perform
      
      logger.info "FINISHED POST TO #{options[:post_url]}: HTTP #{@curb_instance.response_code}"
      return @curb_instance
    end
    
    def fetch_page(url = 'https://www.google.com/voice/inbox/recent')
  
      @curb_instance.url = url #"https://www.google.com/voice/inbox/recent"
      
      @curb_instance.http_get
      
      logger.info "FINISHED FETCHING #{url}: HTTP #{@curb_instance.response_code}"
      return @curb_instance
    end
    
    def parse_page(page_obj)
      doc = Nokogiri::XML.parse(page_obj.body_str)
      
      # p doc
      
      html_fragment = Nokogiri::HTML::DocumentFragment.parse(doc.to_html)
      
      # p html_fragment
      
      m = doc.css('json').first.to_s.scan(/CDATA\[(.+)\]\]/).flatten
      
      inbox = JSON.parse(m.first)
      
      get_unread_counts(inbox)
      parse_sms_messages(inbox['messages'], html_fragment)
      parse_voicemail_messages(inbox['messages'], html_fragment)
      @all_messages = @smss | @voicemails
      @all_messages.sort_by!(&:start_time)
    end
    
    def parse_sms_messages(messages, page_fragment)
      
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
      # p @smss
    end
  
    def parse_voicemail_messages(messages, page_fragment)
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
            vm_obj.transcript = row.css('div.gc-message-message-display').inner_text.to_s.gsub(/\n/, '').strip!
            # vm_obj.time       = row.css('span.gc-message-time').inner_html
          else
            next
          end
        end
      end
    end
    
    def get_unread_counts(inbox)
      @unread_counts = inbox['unreadCounts']
      @any_unread = inbox['unreadCounts']['unread'].to_i != 0
      logger.info "No unread messages in your Google Voice inbox." unless @any_unread
    end
    
    def set_rnr_se_token
      if @curb_instance.instance_of?(Curl::Easy) && @curb_instance.response_code == 200
        @curb_instance.url = "http://www.google.com/voice"
        @curb_instance.perform 
        @_rnr_se = Nokogiri::HTML::Document.parse(@curb_instance.body_str).css('form#gc-search-form').inner_html
        /value="(.+)"/.match(@_rnr_se)
        @_rnr_se = $1
      else
        raise IOError, "Curb instance was not properly initialized."  
      end
    end
  end
end