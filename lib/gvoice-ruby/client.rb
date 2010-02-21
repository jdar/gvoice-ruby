# coding: UTF-8
$:.unshift(File.dirname(__FILE__))
%w[curb nokogiri json sms voicemail user logger compatibility inbox_parser open-uri].each { |lib| require lib }

module GvoiceRuby
  class Client
    include Curl
    
    attr_accessor :page, :unread_counts, :start_times, :smss, :voicemails, :user, :all_messages
    attr_reader :logger
    
    def initialize(config = GvoiceRuby::Configurator.load_config)
      if config[:google_account_email].nil? || config[:google_account_password].nil?
        raise ArgumentError, "Invalid Google Account username or password provided."
      else          
        @logger        = Logger.new(File.join(File.dirname(__FILE__), '..', '..', 'log', 'gvoice-ruby.log'))
        @user          = User.new(config[:google_account_email], config[:google_account_password])
        @curb_instance = login(config)
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
    
    def check(parser = GvoiceRuby::InboxParser.new)
      inbox = parser.parse_page(fetch_page)
      
      get_unread_counts(inbox)
      smss = parser.parse_sms_messages(inbox['messages'])
      voicemails = parser.parse_voicemail_messages(inbox['messages'])
      @all_messages = smss | voicemails
      @all_messages.sort_by!(&:start_time)
    end
    
    def archive(options) 
      post_page(:archive, options)
    end
    
    def mark_as_read(options) 
      post_page(:mark_as_read, options)
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
        
        defeat_google_xsrf(curl.body_str)

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
      when /archive/
        fields = [ PostField.content('messages', options[:id]),
                   PostField.content('archive', 1),
                   PostField.content('_rnr_se', @_rnr_se) ]
      when /mark_as_read/
        fields = [ PostField.content('messages', options[:id]),
                   PostField.content('read', 1),
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
    
    def get_unread_counts(inbox)
      @unread_counts = inbox['unreadCounts']
      @any_unread = inbox['unreadCounts']['unread'].to_i != 0
      logger.info "No unread messages in your Google Voice inbox." unless @any_unread
    end
    
    def defeat_google_xsrf(body_string)
      # defeat Google's XSRF protection
      doc = Nokogiri::HTML::DocumentFragment.parse(body_string)
      doc.css('div.loginBox table#gaia_table input').each do |input|
        if input.to_s =~ /GALX/
          @galx = input.to_s.scan(/value\="(.+?)"/).flatten!.pop
          # p @galx
        else
        end
      end
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