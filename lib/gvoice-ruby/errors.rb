# -*- encoding: utf-8 -*-
module GvoiceRuby
  class LoginFailed < StandardError
  end
  
  class NetworkError < StandardError
    def to_s
      super
      puts "Unable to connect to Google Voice!"
    end
  end
end